package com.telerik.sendgrid;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.*;

import android.net.Uri;

import com.sendgrid.*;


public class SendGridPlugin extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("sendWithWeb")) {
            try {
				      this.send(callbackContext, args.getJSONObject(0));
			      }
            catch (Exception e) {
				      callbackContext.error(e.getMessage());
			     }
           return true;
        }
        return false;
    }

    private void send(final CallbackContext callbackContext, final JSONObject jsonObject) throws JSONException, IOException {

      int appResId = cordova.getActivity().getResources().getIdentifier("sendgrid_api_user", "string", cordova.getActivity().getPackageName());
      String apiUser = cordova.getActivity().getString(appResId);

      appResId = cordova.getActivity().getResources().getIdentifier("sendgrid_api_key", "string", cordova.getActivity().getPackageName());

      String apiKey = cordova.getActivity().getString(appResId);

      final SendGrid sendgrid = new SendGrid(apiUser, apiKey);
      final SendGrid.Email email = new SendGrid.Email();

      email.addTo(jsonObject.getString("to"));
      email.setFrom(jsonObject.getString("from"));
      email.setSubject(jsonObject.getString("subject"));

      if (jsonObject.has("text"))
        email.setText(jsonObject.getString("text"));

      if (jsonObject.has("html"))
        email.setHtml(jsonObject.getString("html"));

      if (jsonObject.has("files")){
    	  JSONArray jsonArray = jsonObject.getJSONArray("files");

    	  for(int index = 0; index < jsonArray.length(); index++) {
    		    String path = jsonArray.getString(index);
    		    Uri uri = Uri.parse(path);

    		    File file = new File(uri.getPath());

    	    	if (file != null){
    	           email.addAttachment(file.getName(), file);
    	        }
    	  }
      }

      try {
           SendGrid.Response response = sendgrid.send(email);
           callbackContext.success(new JSONObject(response.getMessage()));
      }
      catch (Exception e) {
        callbackContext.error(e.getMessage());
      }
    }
}
