  var GlobalNav = GlobalNav || {};

  GlobalNav.TwoMinutesTimeout = 2*60000;


  GlobalNav.subdomainToLangMappings = {
        "cn": "zh",
        "jp": "ja",
        "kr": "ko",
        "la": "es",
        "es": "es",
        "fr": "fr",
        "it": "it",
        "de": "de"
      };


      /* translations */
      GlobalNav.mwa_dropdown_labels = {
          "en": {
            "title_mobile_tablet": "Sign In <span class=\"sr-only\">to Your MathWorks Account</span>",
            "title": "Sign In to Your MathWorks Account",
            "message": "Access your MathWorks Account",
            "myAccount": "My Account",
            "associateLicense": "Link License",
            "communityProfile": "My Community Profile",
            "signout": "Sign Out"
          },
          "zh": {
            "title_mobile_tablet": "登录<span class=\"sr-only\">到您的 MathWorks 帐户</span>",
            "title": "登录到您的 MathWorks 帐户",
            "message": "Access your MathWorks Account",
            "myAccount": "我的帐户",
            "associateLicense": "关联许可证",
            "communityProfile": "我的社区资料",
            "signout": "注销"
          },
          "ja": {
            "title_mobile_tablet": "<span class=\"sr-only\">MathWorks アカウントへの</span>サインイン",
            "title": "MathWorks アカウントへのサインイン",
            "message": "Access your MathWorks Account",
            "myAccount": "アカウント",
            "associateLicense": "ライセンスを関連付ける",
            "communityProfile": "コミュニティのプロファイル",
            "signout": "サインアウト"
          },
          "ko": {
            "title_mobile_tablet": "<span class=\"sr-only\">MathWorks 계정</span>에 로그인합니다.",
            "title": "MathWorks 계정에 로그인합니다.",
            "message": "Access your MathWorks Account",
            "myAccount": "My account",
            "associateLicense": "라이선스를 계정에 연결",
            "communityProfile": "나의 커뮤니티 프로필",
            "signout": "로그아웃"
          },
          "es": {
            "title_mobile_tablet": "Inicie sesión con su <span class=\"sr-only\">cuenta de MathWorks</span>",
            "title": "Inicie sesión con su cuenta de MathWorks",
            "message": "Access your MathWorks Account",
            "myAccount": "Mi Cuenta",
            "associateLicense": "Asociar Licencia",
            "communityProfile": "Mi perfil de la comunidad",
            "signout": "Cerrar sesión"
          },
          "fr": {
            "title_mobile_tablet": "Sign In <span class=\"sr-only\">to Your MathWorks Account</span>",
            "title": "Se connecter",
            "message": "Access your MathWorks Account",
            "myAccount": "Mon Compte",
            "associateLicense": "Mes licences",
            "communityProfile": "Mon profil",
            "signout": "Se d&eacute;connecter"
          },
          "it": {
            "title_mobile_tablet": "Accedere al <span class=\"sr-only\">proprio MathWorks Account</span>",
            "title": "Accedere al proprio MathWorks Account",
            "message": "Access your MathWorks Account",
            "myAccount": "Il Mio Account",
            "associateLicense": "Associa Licenza",
            "communityProfile": "Il mio Profilo utente",
            "signout": "Disconnetti"
          },
          "de": {
            "title_mobile_tablet": "Melden Sie sich <span class=\"sr-only\">bei Ihrem MathWorks Konto</span>an",
            "title": "Melden Sie sich bei Ihrem MathWorks Konto an",
            "message": "Access your MathWorks Account",
            "myAccount": "Eigener Account",
            "associateLicense": "Lizenz zuordnen",
            "communityProfile": "Mein Community Profil",
            "signout": "Abmelden"
          }
        };

GlobalNav.getMWACookieNames = function(domain) {
                var mwaLoginCookieName = 'mwa';
                var mwaLoginProfileCookieName = 'mwa_profile';
                var mwaPrefsCookieName = 'mwa_prefs';

                var subdomainSuffix;
                var subdomainParts;

                try{
                  subdomainParts = domain.split('.')[0].split('-');
                }catch(error){
                  throw new Error("Invalid domain while parsing for cookie names");
                }

                if (subdomainParts.length > 1) {
                        subdomainSuffix = subdomainParts[subdomainParts.length - 1];
                        mwaLoginCookieName = mwaLoginCookieName + '_' + subdomainSuffix;
                        mwaLoginProfileCookieName = mwaLoginProfileCookieName + '_' + subdomainSuffix;
                        mwaPrefsCookieName = mwaPrefsCookieName + '_' + subdomainSuffix;
                }

                return {
                        mwaLoginCookieName: mwaLoginCookieName,
                        mwaLoginProfileCookieName: mwaLoginProfileCookieName,
                        mwaPrefsCookieName: mwaPrefsCookieName
                };
};

GlobalNav.getDomain = function(url) {
                var domain="";

                if(url){
                  var segments = url.split('/');
                  if(segments.length>2){
                    domain = segments[2];
                  }else{
                    throw new Error("Invalid Url while parsing for domain");
                  }
            }else{
              throw new Error("Url is empty while parsing for domain");
            }
                return domain;
};

GlobalNav.getSubdomain = function(domain) {
  try{
       var subdomainParts = domain.split('.')[0].split('-');
       return subdomainParts[0];
    }catch(error){
      throw new Error("Invalid domain while parsing for subdomain");
    }
};

GlobalNav.getEnvironment = function(domain) {
  try{
       var subdomainParts = domain.split('.')[0].split('-');
       if(typeof subdomainParts[1] === 'undefined'){
      return "prod";
       }else{
        return subdomainParts[1];
       }
    }catch(error){
       return "prod";
    }
};

GlobalNav.getCookieValue = function(cookieName) {
  // regex from: https://developer.mozilla.org/en-US/docs/Web/API/Document/cookie
  var cookieRegex = new RegExp("(?:(?:^|.*;\\s*)"+cookieName+"\\s*\\=\\s*([^;]*).*$)|^.*$");
  if (document.cookie) {
    var cookieValue = document.cookie.replace(cookieRegex, "$1");
    if (cookieValue) {
      try{
        return JSON.parse(decodeURIComponent(cookieValue));
      }catch(error){
        return "";
      }
    }
  }
  return "";
};

GlobalNav.getLang = function(subdomain, mwaPrefsCookie) {
  var lang="";

    var prefCookieValue=GlobalNav.getCookieValue(mwaPrefsCookie);

    if(subdomain=="ch"){
      if(prefCookieValue && prefCookieValue.lang){
        lang=prefCookieValue.lang;
      }else{
          lang="en";
      }
    }else if(subdomain=="ww2"){
      if(prefCookieValue && prefCookieValue.lang){
        lang=prefCookieValue.lang;
      }else{
          lang="zh";
      }
    }else{
      //read from subdomain(cn domain is interesting)
      if(GlobalNav.subdomainToLangMappings[subdomain]){
        lang=GlobalNav.subdomainToLangMappings[subdomain];
      }else{
        lang="en";
      }
    }

    return lang;
};


GlobalNav.setCookies = function (domain, cookieName, cookieValue, timeout_minutes) {
  var cookieDomain = '.mathworks.com';
  if (GlobalNav.endsWith(domain, 'mathworks.cn')) {
    cookieDomain = '.mathworks.cn';
  }

  var expires = new Date();
  expires.setTime(expires.getTime() + GlobalNav.TwoMinutesTimeout);
  document.cookie=cookieName+"="+encodeURIComponent(JSON.stringify(cookieValue))+";"+"expires="+expires.toGMTString()+";domain="+cookieDomain+";path=/";
};

GlobalNav.endsWith = function( str, suffix ) {
  return str.substring( str.length - suffix.length, str.length ) === suffix;
}

// Need override as certain pages shouldn't be redirected to
GlobalNav.redirectUrl = function(){
  return window.customGlobalNavRedirectUrl || window.location.href;
}

GlobalNav.showLoggedInHTML = function(langKey, image, loginDisplayName){
      var defaultImage='/images/responsive/global/ico-header-account-active.svg';//green logged-in icon

      var liHeaderNav=$("<li></li>").addClass('headernav_login').addClass('dropdown');

      var loggedInLink = $("<a></a>").attr('href', '#').addClass('dropdown-toggle mwa_image_drop_down').attr('data-toggle', 'dropdown').
      attr('style','background-image:url('+image+'), url('+defaultImage+')').attr('role','button')
      .attr('aria-haspopup','true').attr('aria-expanded','false');

      var parentLargeMobileSpanTag=$("<span></span>").addClass('visible-lg').addClass('visible-md');
      var childMobileSpanTag=$("<span></span>").addClass('sr-only').html(GlobalNav.mwa_dropdown_labels[langKey]["message"]);

      parentLargeMobileSpanTag.append(childMobileSpanTag.clone());

      var mobileSpanTag =$("<span></span>").addClass('visible-xs').addClass('visible-sm');
      mobileSpanTag.append($("<span></span>").addClass('mobile_account_image').attr('style','background-image:url('+image+'), url('+defaultImage+')'))
               .append(childMobileSpanTag.clone())
               .append($("<span></span>").attr('aria-hidden','true').html(loginDisplayName))
               .append($("<b></b>").addClass('caret'));

      loggedInLink.append(parentLargeMobileSpanTag);
      loggedInLink.append(mobileSpanTag);

      var dropdown = $("<ul></ul>").addClass('dropdown-menu').attr('role','menu')
          .append($("<li></li>").addClass('mwa-nav_account').html($("<a></a>").attr('href','/mwaccount/').html(GlobalNav.mwa_dropdown_labels[langKey]["myAccount"])))
          .append($("<li></li>").addClass('mwa-nav_community').html($("<a></a>").attr('href','/matlabcentral/profile/authors/my_profile?s_tid=gn_comm').html(GlobalNav.mwa_dropdown_labels[langKey]["communityProfile"])))
          .append($("<li></li>").addClass('mwa-nav_associate').html($("<a></a>").attr('href','/licensecenter/workflows/associate_license?s_tid=gn_aslc').html(GlobalNav.mwa_dropdown_labels[langKey]["associateLicense"])))
          .append($("<li></li>").addClass('mwa-nav_logout').html($("<a></a>").attr('href','/login/logout?uri='+ encodeURIComponent(GlobalNav.redirectUrl())).html(GlobalNav.mwa_dropdown_labels[langKey]["signout"])));

      var matrixHeaderNav = $("<li></li>").attr('id','headernav_matrix').addClass('headernav_matrix');

      liHeaderNav.append(loggedInLink);
      liHeaderNav.append(dropdown);

      liHeaderNav.appendTo("#headernav");
      matrixHeaderNav.appendTo('#headernav');
      liHeaderNav.clone().prependTo("#header_mobile #topnav_mobile");
};

GlobalNav.showLoggedOutHtml=function(langKey){
      var liHeaderNav=$("<li></li>").addClass('headernav_login');

      var loginLink = $("<a></a>").attr('href', '/login?uri='+ encodeURIComponent(GlobalNav.redirectUrl())).addClass('mwa-nav_login');

      var parentSmallMobileSpanTag =$("<span></span>").addClass('visible-xs').addClass('visible-sm').html(GlobalNav.mwa_dropdown_labels[langKey]["title_mobile_tablet"]);

      var parentLargeMobileSpanTag=$("<span></span>").addClass('visible-lg').addClass('visible-md');
      var childMobileSpanTag=$("<span></span>").addClass('sr-only').html(GlobalNav.mwa_dropdown_labels[langKey]["title"]);
      parentLargeMobileSpanTag.append(childMobileSpanTag.clone());

      loginLink.append(parentSmallMobileSpanTag);
      loginLink.append(parentLargeMobileSpanTag);

      liHeaderNav.append(loginLink);

      var matrixHeaderNav = $("<li></li>").attr('id','headernav_matrix').addClass('headernav_matrix');

      liHeaderNav.appendTo("#headernav");
      matrixHeaderNav.appendTo('#headernav');
      liHeaderNav.clone().prependTo("#header_mobile #topnav_mobile");
};

GlobalNav.setNewImage=function(mwaProfileValue){
  if(mwaProfileValue.profile && mwaProfileValue.profile.profilePicture){
    var image='/matlabcentral/profiles/'+mwaProfileValue.profile.profilePicture;
    $('.mwa_image_drop_down').attr('style','background-image:url('+image+')');
      $('.mobile_account_image').attr('style','background-image:url('+image+')');
  }
};

document.addEventListener('DOMContentLoaded',function () {
    'use strict';

    try{

      var currentUrl = window.location.href;
      var currentDomain = GlobalNav.getDomain(currentUrl);
      var subDomain = GlobalNav.getSubdomain(currentDomain);
      var cookieNames = GlobalNav.getMWACookieNames(currentDomain);

      var mwaLoginCookieName = cookieNames.mwaLoginCookieName;
      var mwaLoginProfileCookieName = cookieNames.mwaLoginProfileCookieName;
      var mwaPrefsCookie = cookieNames.mwaPrefsCookieName;

      var langKey=GlobalNav.getLang(subDomain, mwaPrefsCookie);

      if(GlobalNav.getCookieValue(mwaLoginCookieName)){
        var image='/images/responsive/global/ico-header-account-active.svg';//green logged-in icon
        var mwaProfileValue=GlobalNav.getCookieValue(mwaLoginProfileCookieName);
        var loginDisplayName='';

        if(mwaProfileValue){
          if(mwaProfileValue.profile && mwaProfileValue.profile.profilePicture){
            image='/matlabcentral/profiles/'+mwaProfileValue.profile.profilePicture;
          }else{
            $.post('/mwaccount/profiles/avatar');
            GlobalNav.setCookies(currentDomain, mwaLoginProfileCookieName, mwaProfileValue, GlobalNav.defaultCookieTimeoutInMinutes);
          }
          if(mwaProfileValue.profile && mwaProfileValue.profile.loginDisplayName){
            loginDisplayName=mwaProfileValue.profile.loginDisplayName;
          }
        }else{
          $.get('/login/cookies/refresh?uri=' + encodeURIComponent(currentUrl)).done(function(){
            var newMWAProfileValue=GlobalNav.getCookieValue(mwaLoginProfileCookieName);
            GlobalNav.setNewImage(newMWAProfileValue);
          });
        }

        GlobalNav.showLoggedInHTML(langKey, image, loginDisplayName);
      } else {
        GlobalNav.showLoggedOutHtml(langKey);
      }

      var script = document.createElement('script');
      script.type = 'text/javascript';
      script.src = '/includes_content/responsive/scripts/matrix/main.min.js';
      script.onload = function(){
        matrix.show({
         largeId: "headernav_matrix",
         smallId: ["matrix_affordance_container_mobile", "matrix_menu_container_mobile"],
         env: GlobalNav.getEnvironment(currentDomain),
         tier: "DOTCOM",
         lang: langKey
         });
      };
      document.body.appendChild(script);
  }catch(error){
    console.log(error.message);
  }

});

