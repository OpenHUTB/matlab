function ff=socVideoTestStimulusMap(fs)
    switch fs
    case '480p SDTV (720x480p)',apl=720;avl=480;tpl=858;tvl=525;sal=37;fp=16;
    case '576p SDTV (720x576p)',apl=720;avl=576;tpl=864;tvl=625;sal=45;fp=12;
    case '720p HDTV (1280x720p)',apl=1280;avl=720;tpl=1650;tvl=750;sal=26;fp=110;
    case '1080p HDTV (1920x1080p)',apl=1920;avl=1080;tpl=2200;tvl=1125;sal=42;fp=88;
    case '160x120p',apl=160;avl=120;tpl=180;tvl=140;sal=11;fp=10;
    case '320x240p',apl=320;avl=240;tpl=402;tvl=324;sal=1;fp=44;
    case '640x480p',apl=640;avl=480;tpl=800;tvl=525;sal=36;fp=16;
    case '800x600p',apl=800;avl=600;tpl=1056;tvl=628;sal=28;fp=40;
    case '1024x768p',apl=1024;avl=768;tpl=1344;tvl=806;sal=36;fp=24;
    case '1280x768p',apl=1280;avl=768;tpl=1664;tvl=798;sal=28;fp=64;
    case '1280x1024p',apl=1280;avl=1024;tpl=1688;tvl=1066;sal=42;fp=48;
    case '1360x768p',apl=1360;avl=768;tpl=1792;tvl=795;sal=25;fp=64;
    case '1366x768p',apl=1366;avl=768;tpl=1792;tvl=798;sal=28;fp=70;
    case '1400x1050p',apl=1400;avl=1050;tpl=1864;tvl=1089;sal=37;fp=88;
    case '1600x1200p',apl=1600;avl=1200;tpl=2160;tvl=1250;sal=50;fp=64;
    case '1680x1050p',apl=1680;avl=1050;tpl=2240;tvl=1089;sal=37;fp=104;
    case '1920x1200p',apl=1920;avl=1200;tpl=2080;tvl=1235;sal=33;fp=48;
    case '16x12p',apl=16;avl=12;tpl=18;tvl=14;sal=2;fp=1;
    otherwise
        error('bad frameSize case');
    end
    ff=struct('ActivePixelsPerLine',apl,'ActiveVideoLines',avl,...
    'TotalPixelsPerLine',tpl,'TotalVideoLines',tvl,...
    'StartingActiveLine',sal,'FrontPorch',fp);
end
