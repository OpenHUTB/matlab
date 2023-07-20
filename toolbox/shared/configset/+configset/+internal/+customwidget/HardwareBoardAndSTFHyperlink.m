function out=HardwareBoardAndSTFHyperlink(cs,name,direction,widgetVals)



    cs=cs.getConfigSet;

    if direction==0
        if isempty(cs)
            out={'','',''};
        else
            stf=cs.get_param('SystemTargetFile');
            if strcmp(stf,'realtime.tlc')
                if cs.isValidParam('TargetExtensionPlatform')
                    board=cs.get_param('TargetExtensionPlatform');
                else
                    board='';
                end
            else
                board=cs.get_param(name);
            end
            out={board,stf,''};
        end
    elseif direction==1
        out=widgetVals{1};
    end

