@RestResource(urlMapping='/slack/slackwebhook')
global class SlackWebhookHandler {
    @HttpPost
    global static void handleWebhook() {
        System.debug('In web service');
        System.debug(RestContext.request.params);
        System.Debug(RestContext.request.params.get('payload'));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.params.get('payload'));
        System.debug(responseMap.get('user'));
        Map<String, Object> userMap = (Map<String, Object>)responseMap.get('user');
        String slackUserId = (String)userMap.get('id');
        String userName = (String)userMap.get('name');
        System.debug(slackUserId);
        Map<String, Object> channelMap = (Map<String, Object>)responseMap.get('channel');
        String channelId = (String)channelMap.get('id');
        System.debug(channelId);
        String timeStamp = (String)responseMap.get('message_ts');
        System.debug(timeStamp);
        String token = (String)responseMap.get('token');
        System.debug(token);
        List<Object> actionsList = (List<Object>)responseMap.get('actions');
        Map<String, Object> mMap = (Map<String, Object>)actionsList[0];
        String leadId = (String)mMap.get('value');
        
        Id userId = [SELECT Id,Slack_User_Id__c FROM User WHERE Slack_User_Id__c=:slackUserId].Id;
        Lead leadToUpdate = [SELECT Id, OwnerId FROM Lead WHERE Id = :leadId LIMIT 1];
        leadToUpdate.OwnerId = userId;

        update leadToUpdate;
        updateMessage(channelId,timeStamp,token,userName,leadId);

        RestContext.response.statusCode = 200;
    }

    @future(callout =true)
    public static void updateMessage(String channelId,String timeStamp, String token,String userName,String leadId){
        String leadName = [SELECT Id,Name FROM Lead WHERE Id=:leadId].Name;
        String slackToken = 'xoxb-5694868055078-5714176581331-KcJ02va74izgPYRDthY0qRey';
        String slackApiEndpoint = 'https://slack.com/api/chat.update';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(slackApiEndpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + slackToken);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('token', token);
        
        Map<String, Object> reqBody = new Map<String, Object>{
            'channel' => channelId,
            'ts' => timeStamp,
            'attachments' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'text' => 'Lead(LeadName - '+leadName+') has been assigned to '+userName,
                    'fallback' => 'You are unable to choose an action',
                    'callback_id' => 'interactive_message'
                }
            }
        };
        
        String jsonString = JSON.serialize(reqBody);
        
        System.debug(jsonString);

        //String payload = '{"channel": "C05LSCV4H4N", "text": "' + message + '", "attachments": '++'}';
        req.setBody(jsonString);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            System.debug('Slack API Error: ' + res.getBody());
        }
    }
}