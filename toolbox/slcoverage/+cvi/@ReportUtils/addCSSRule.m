function outStr=addCSSRule(inStr,rule)



    outStr='';
    if strcmpi(rule,'p.descr')
        outStr=['<p class="descr">',inStr,'</p>'];
    end