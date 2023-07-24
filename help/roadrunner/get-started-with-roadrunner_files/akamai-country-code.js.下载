// Fake the CQ_Analytics stuff to set a global variable that can be checked in the test

var CQ_Analytics = {
   'ClientContextMgr': {
      'getRegisteredStore': function(x) {
    	  var countryCodeResult = null;
         return {
            'getProperty': function(type) {
                if (type === 'countryCode') {
                	var countryCode = "CN";
                	if(countryCode.length === 2){
                		return countryCode;
                	}
                   return null;
                }
             }
         };
      }
   }
};
