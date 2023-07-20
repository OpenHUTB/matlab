function[simpleImage,emptyMask]=isSimpleImageMask(block)









    if isa(block,'Simulink.Mask')
        maskDisplayString=block.Display;
    else
        maskDisplayString=get_param(block,'MaskDisplay');
    end

    simpleImage=false;

    lines=strtrim(strsplit(maskDisplayString,newline));


    lines=lines(~cellfun('isempty',lines));


    lines=lines(cellfun('isempty',regexp(lines,'^\s*%','once')));
    emptyMask=isempty(lines);
    if emptyMask

        return;
    end

    if numel(lines)~=1

        return;
    end



    pattern='\s*image\s*\(\s*''.*''\s*\)\s*(;)?\s*(%.*)?$';
    simpleImage=~isempty(regexp(lines{1},pattern,'once'));
end
