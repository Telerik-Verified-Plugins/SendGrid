#import "CDVSendGrid.h"


#import "SendGridEmail.h"
#import "SendGrid.h"


@implementation CDVSendGrid

- (void)sendWithWeb:(CDVInvokedUrlCommand*)command
{
    __block CDVPluginResult* pluginResult = nil;

    NSDictionary* body = [command.arguments objectAtIndex:0];

    if (body != nil) {
        NSString *apiUser = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SendGridApiUser"];
        NSString *apiKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SendGridApiKey"];

        SendGrid *sendGrid = [SendGrid apiUser:apiUser apiKey:apiKey];

        SendGridEmail *sendGridEmail = [[SendGridEmail alloc] init];

        if ([body objectForKey:@"to"])
            [sendGridEmail setTo:[body objectForKey:@"to"]];
        if ([body objectForKey:@"from"])
            [sendGridEmail setFrom:[body objectForKey:@"from"]];
        if ([body objectForKey:@"subject"])
            [sendGridEmail setSubject:[body objectForKey:@"subject"]];
        if ([body objectForKey:@"text"])
            [sendGridEmail setText:[body objectForKey:@"text"]];
        if ([body objectForKey:@"html"])
            [sendGridEmail setHtml:[body objectForKey:@"html"]];
        if ([body objectForKey:@"toname"])
            [sendGridEmail setToName:[body objectForKey:@"toname"]];
        if ([body objectForKey:@"fromname"])
            [sendGridEmail setFromName:[body objectForKey:@"fromname"]];
        if ([body objectForKey:@"replyto"])
            [sendGridEmail setReplyTo:[body objectForKey:@"replyto"]];
        if ([body objectForKey:@"bcc"]
            && [[body objectForKey:@"bcc"] isKindOfClass:[NSArray class]])
            [sendGridEmail setBcc:[body objectForKey:@"bcc"]];

        if ([body objectForKey:@"files"]){

            NSArray *paths = [body objectForKey:@"files"];

            for (NSString *path in paths){
                // normalize
                NSString *relativePath = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];

                UIImage *image = [UIImage imageWithContentsOfFile:relativePath];
                [sendGridEmail attachImage:image];
            }
        }

        [sendGrid sendWithWeb:sendGridEmail successBlock:^(id result) {
            if ([[result objectForKey:@"message"] isEqualToString:@"success"])
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
            else
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:result];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            });

        } failureBlock:^(NSError *error) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            });
        }];
    }
}

@end
