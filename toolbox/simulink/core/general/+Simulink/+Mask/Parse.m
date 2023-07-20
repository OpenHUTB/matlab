

function svgString=Parse(obj)
    svgString='';
    if(isempty(obj.MaskDefinition)||isnull(mtree(obj.MaskDefinition)))
        return;
    end
    newSystem=new_system();
    destPath=[get_param(newSystem,'Name'),'/Block'];




    add_block(obj.BlockHandle,destPath);
    Simulink.Mask.scb(destPath);

    obj.PreProcess();
    svgString=obj.EvaluateMtree(obj.MaskDefinition);
    if(~isempty(obj.SVGPath))
        svgString=fileread(obj.SVGPath);
        obj.SVGString=svgString;
        obj.success=true;
        return;
    end
    obj.SVGString=svgString;
    Simulink.Mask.MakeSVG(obj);
    obj.success=true;
    close_system(newSystem,0);
end