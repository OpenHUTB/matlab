function block2Link(curBadBlock,refstring,tempSys,varargin)









    baseParamsToCopy={...
'Tag'...
    ,'Description'...
    ,'RequirementInfo'...
    ,'Position'...
    ,'Orientation'...
    ,'ForegroundColor'...
    ,'BackgroundColor'...
    ,'DropShadow'...
    ,'NamePlacement'...
    ,'ShowName'...
    ,'Priority'...
    ,'AttributesFormatString'...
    ,'RTWdata'...
    ,'FontName'...
    ,'FontSize'...
    ,'FontWeight'...
    ,'FontAngle'...
    ,'IOType'...
    ,'UserDataPersistent'...
    ,'UserData'...
    ,'Diagnostics'...
    ,'StatePerturbationForJacobian'...
    ,'IOSignalStrings'...
    ,'ExtModeUploadOption'...
    ,'ExtModeLoggingTrig'...
    };

    safelyIgnoredParameters={'DblOver';'dolog';'EnableZeroCross'};

    tempBlk=[tempSys,'/junkblock'];

    curNewRefBlock=sprintf(refstring);
    curRefLibName=strtok(refstring,'/');
    load_system(curRefLibName);
    add_block(curNewRefBlock,tempBlk);

    try


        curParamNames=get_param(curBadBlock,'MaskNames');
        curParamNames=[baseParamsToCopy,curParamNames(:)'];



        origFeat=slfeature('DeprecateObsoleteDataTypePrms',0);
        restoreFeat=onCleanup(@()slfeature('DeprecateObsoleteDataTypePrms',origFeat));

        try





            strToEval='set_param(tempBlk';

            curParamValues=cell(length(curParamNames),1);
            for k=1:length(curParamNames)

                curNameOfParam=curParamNames{k};

                if any(strcmp(safelyIgnoredParameters,curNameOfParam))
                    continue
                end

                curValueOfMaskParam=get_param(curBadBlock,curNameOfParam);
                curParamValues{k}=curValueOfMaskParam;
                kStr=sprintf('%d',k);
                strToEval=[strToEval,',curParamNames{',kStr,'},curParamValues{',kStr,'}'];%#ok

            end

            strToEval=[strToEval,');'];
            eval(strToEval);

        catch e %#ok<*NASGU>


            for k=1:length(curParamNames)

                strToEval='set_param(tempBlk';
                curNameOfParam=curParamNames{k};
                curValueOfMaskParam=get_param(curBadBlock,curNameOfParam);
                curParamValues{k}=curValueOfMaskParam;
                kStr=num2str(k);
                strToEval=[strToEval,',curParamNames{',kStr,'},curParamValues{',kStr,'}'];%#ok
                strToEval=[strToEval,');'];%#ok

                try
                    eval(strToEval);
                catch e

                end

            end

        end



        if nargin>3
            try
                varargin{1}(curBadBlock,tempBlk);
            catch e
                warning(e.identifier,'%s',e.message);
            end
        end


        delete_block(curBadBlock);






        add_block(tempBlk,curBadBlock);

    catch e
        warning(e.identifier,'%s',e.message)
    end

    delete_block(tempBlk);

end
