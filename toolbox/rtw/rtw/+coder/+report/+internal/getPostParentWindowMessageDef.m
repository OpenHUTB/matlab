




function out=getPostParentWindowMessageDef()
    out=['function postParentWindowMessage(message) {'...
    ,'window.parent.postMessage(message, "*");'...
    ,'}'
    ];
end