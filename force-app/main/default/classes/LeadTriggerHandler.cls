public class LeadTriggerHandler {
    public static void postMessage(List<Lead> leadList){
        for(lead l: leadList){
            String message = 'The following Lead has been created:\nName : '+l.LastName+'\nWith Status : '+l.Status+'\nWith Lead Id : '+l.Id;
            postMessageInChannel(message, l.Id);
        }

    }

    @future(callout =true)
    public static void postMessageInChannel(String message,Id leadId){
        String slackToken = 'xoxb-5694868055078-5714176581331-KcJ02va74izgPYRDthY0qRey';
        String slackApiEndpoint = 'https://slack.com/api/chat.postMessage';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(slackApiEndpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + slackToken);
        req.setHeader('Content-Type', 'application/json');
        
        Map<String, Object> interactiveMessage = new Map<String, Object>{
            'channel' => 'C05LSCV4H4N',
            'text' => message,
            'attachments' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'text' => 'Click on the button to become owner of lead mentioned above',
                    'fallback' => 'You are unable to choose an action',
                    'callback_id' => 'interactive_message',
                    'color' => '#3AA3E3',
                    'attachment_type' => 'default',
                    'actions' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                            'name' => 'claim',
                            'text' => 'Claim',
                            'type' => 'button',
                            'value' => leadId
                        }
                    }
                }
            }
        };
        
        String jsonString = JSON.serialize(interactiveMessage);
        
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