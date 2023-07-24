function getProductFilteredList(mystylesheetLocation, mysourceLocation, product_help_location, pagetype, doccentertype, langcode) {
   var d1 = getProductsDeferred();
   var d2 = undefined;

   var connectorDocSource = getConnectorDocSource();
   if (connectorDocSource) {
      d2 = getAdditionalProductsDeferred();
   }

   var docsetJsonToXmlDeferred = getDocsetJsonToXmlDeferred(mysourceLocation);

   $.when(docsetJsonToXmlDeferred).done(function(docsetXml) { // get data from docset.json and convert to xml format
      if (d2) {
        $.when(d1,d2).done(function (v1,v2) {
           doSaxonCall(mystylesheetLocation, docsetXml, product_help_location, pagetype, doccentertype, langcode, v1,v2);
        }).fail(function (jqXHR, textStatus, error) {
           doSaxonCall(mystylesheetLocation, docsetXml, product_help_location, pagetype, doccentertype, langcode);
        });
      } else {
        $.when(d1).done(function (v1) {
           doSaxonCall(mystylesheetLocation, docsetXml, product_help_location, pagetype, doccentertype, langcode, v1);
        }).fail(function (jqXHR, textStatus, error) {
           doSaxonCall(mystylesheetLocation, docsetXml, product_help_location, pagetype, doccentertype, langcode);
        });
      }  
   });
}

function getAdditionalProductsDeferred() {
   var deferred = $.Deferred(function() {});
   var services = {"messagechannel":"prodfilter"};
   var errorhandler = function() {
      deferred.reject();
   }
   var successhandler = function(data) {
      deferred.resolve(data);
   }
   requestHelpService({}, services, successhandler, errorhandler);
   return deferred;   
}

function getDocsetJsonToXmlDeferred(mysourceLocation) {
   var deferred = $.Deferred(function() {});
    var errorhandler = function(err, textStatus, jqXHR) {
        deferred.reject();
    }
    var successhandler = function(data) {
        var docset = {};
        docset['documentation_set'] = {'format': 'helpcenter',
           'product_list': data.documentation_set.product_list,
           'addon_list': data.documentation_set.addon_list
        };
        var xmldata = cleanupXml(convertObjectToXml(docset));
        deferred.resolve(xmldata);
    }

    var docsetJson = mysourceLocation.split("docset.xml")[0] + "docset.json";
    $.getJSON(docsetJson)
    .done(successhandler)
    .fail(errorhandler);

    return deferred;
}

function doSaxonCall(mystylesheetLocation, mysourcetext, product_help_location, pagetype, doccentertype, langcode, data1, data2) {
	
   var productfilter_shortnames = [];
   var list_supp_software = []; 
   var list_addons = [];
		 
   if (data1) {
      // filtered products
      var prodlist = data1.prodnavlist;
      if (typeof prodlist === "string") {
         prodlist = $.parseJSON(prodlist);
      }      
	  productfilter_shortnames = new Array(prodlist.length);
      for (var i = 0; i < prodlist.length; i++) {
         productfilter_shortnames[i] = prodlist[i].shortname;
      }
   } 

   if (data2) {
      // hsp
      var addOnList = (typeof data2.addonlist == "string") ? $.parseJSON(data2.addonlist) : data2.addonlist;
      list_addons = new Array(addOnList.length);
      for (var i = 0; i < addOnList.length; i++) {
         list_addons[i] = addOnList[i].displayname.concat("@@",addOnList[i].helplocation);
      }
      // toolboxes
      var toolboxList = (typeof data2.toolboxlist == "string") ? $.parseJSON(data2.toolboxlist) : data2.toolboxlist;
      list_supp_software = new Array(toolboxList.length);
      for (var i = 0; i < toolboxList.length; i++) {
         list_supp_software[i] = toolboxList[i].displayname.concat("@@",toolboxList[i].helplocation);
      }
    } 

    SaxonJS.transform({
       stylesheetLocation: mystylesheetLocation,
       sourceText: mysourcetext,
       stylesheetParams: {
          "doccentertype": doccentertype,
          "product_help_location": product_help_location,
          "pagetype": pagetype,
          "loctype": getLoctype(),
          "langcode": langcode,
          "productfilter_shortnames": productfilter_shortnames,
          "list_supp_software": list_supp_software,
          "list_addons": list_addons
       }
    });
}

function getConnectorDocSource() {
   var supportedSources = getSupportedSources();  
   if(supportedSources.indexOf("mw") > -1) {
      return "mw";
   } else {
      return undefined;
   }
}

function getSupportedSources() {
   var supportedSources;
   var searchSource = getSessionStorageItem('searchsource');
   
   if (searchSource) {
      searchSource = searchSource.replace("+", " ");
      supportedSources = searchSource.split(" ");
   } else {
      supportedSources = [];
   }
   return supportedSources;
}

function getLoctype() {
   // Check for presence of MW_Doc_Template cookie
   const cookieRegexp = /MW_Doc_Template="?([^;"]*)/;
   var cookies = document.cookie;
   var matches = cookieRegexp.exec(cookies);

   if (matches != null) {
      var docCookie = matches[1];
      var parts = docCookie.split(/\|\|/);
      if (parts[0].indexOf("PRODUCT") == -1) { return "web"; };
   };
   return "product";
}

function cleanupXml(xmlstring) {
  return '<?xml version="1.0" encoding="UTF-8"?>' + xmlstring;
}

function convertObjectToXml(obj) {
   var xml = '';
    for (var prop in obj) {
        if (obj[prop] instanceof Array) {
            xml += '<' + prop + '>';
            for (var array in obj[prop]) {
                xml += convertObjectToXml(new Object(obj[prop][array]));
            }
            xml += '</' + prop + '>';
        } else {
            xml += '<' + prop + '>';
            typeof obj[prop] == 'object' ? xml += convertObjectToXml(new Object(obj[prop])) : xml += obj[prop];
            xml += '</' + prop + '>';
        }
    }
   var xml = xml.replace(/<\/?[0-9]{1,}>/g,'');
   xml = xml.replace(/product_list/g, 'product-list');
   xml = xml.replace(/display_name/g, 'display-name');
   xml = xml.replace(/help_location/g, 'help-location');
   xml = xml.replace(/alt_short_name/g, 'alt-short-name');
   xml = xml.replace(/short_name/g, 'short-name');
   xml = xml.replace(/product_family_list/g, 'product-family-list');
   xml = xml.replace(/product_family/g, 'product-family');
   xml = xml.replace(/documentation_set/g, 'documentation-set');
   return xml
}
