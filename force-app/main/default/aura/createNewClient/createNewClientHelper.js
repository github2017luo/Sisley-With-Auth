({
    callWebservice: function (component) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = component.get("c.createCustomer"); //foo - APEX method
        action.setParams({ recordId: component.get("v.recordId") }); //recId - APEX Param

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                //    alert("From server: " + response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The client has been created successfully.",
                    "type": "success"
                });
                toastEvent.fire();
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "message": errors[0].message,
                            "type": "error"
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log("Unknown error");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Unknown error",
                        "type": "error"
                    });
                    toastEvent.fire();
                }
            }
        });

        // optionally set storable, abortable, background flag here

        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    }

})