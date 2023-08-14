


function svgString=MakeSVG(obj)
    svgString=obj.SVGString;
    frameDetails=get_param(obj.BlockHandle,'MaskIconFrame');
    frameDVG='Frame:';
    if(~isempty(frameDetails)&&strcmpi(frameDetails,'off'))
        frameDVG=[frameDVG,'Off'];
    else
        frameDVG=[frameDVG,'Rectangle'];
    end
    backgroundColorOption='';
    if(~isempty(get_param(obj.BlockHandle,'BackgroundColor')))
        backgroundColorOption=[' style="background:'...
        ,get_param(obj.BlockHandle,'BackgroundColor'),'" '];
    end
    svgString=['<?xml-stylesheet href="defaultstyles.css" type="text/css"?>','\n','<?xml-stylesheet href="Simulink.css" type="text/css"?>','\n','<svg width="',string(obj.Width),'" height="',string(obj.Height),'" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:d="http://www.mathworks.com/blockgraphics" ',' d:options="',frameDVG,';','Resize:FitToBlock','"',backgroundColorOption,'>','\n',svgString];
    svgString=[svgString,'\n'];
    svgString=[svgString,'</svg>'];
    svgString=strjoin(svgString,'');
    obj.SVGString=svgString;
end