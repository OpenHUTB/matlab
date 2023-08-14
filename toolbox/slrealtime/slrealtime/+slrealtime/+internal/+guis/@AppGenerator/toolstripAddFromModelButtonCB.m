function toolstripAddFromModelButtonCB(this)






    if isempty(this.SessionSource),return;end



    model=this.SessionSource.ModelName;





    this.ProgressDialog=uiprogressdlg(...
    this.getUIFigure(),...
    'Indeterminate','on',...
    'Message',getString(message('slrealtime:appdesigner:OpeningModel',model)),...
    'Title',this.BindMode_msg);



    try
        open_system(model);
    catch ME
        delete(this.ProgressDialog);
        this.errorDlg('slrealtime:appdesigner:OpenModelError',ME.message);
        return;
    end




    this.ProgressDialog.Message=this.SelectBindings_msg;



    bindObj=slrealtime.internal.SLRTBindModeSourceData(...
    model,...
    slrealtime.internal.SLRTBindModeSourceData.BOTH,...
    @(d)retDataCB(this,d));
    BindMode.BindMode.enableBindMode(bindObj);
end

function retDataCB(this,dataMap)



    c=onCleanup(@()delete(this.ProgressDialog));

    data=[];
    if~isempty(dataMap)
        data=dataMap.values;
    end



    this.bringToFront();



    for i=1:length(data)

        blockPath=strrep(data{i}.hierarchicalPathArr(2:end),newline,' ');
        if length(blockPath)==1
            blockPath=blockPath{1};
        end


        if iscell(blockPath)
            bp=blockPath{end};
        else
            bp=blockPath;
        end
        indices=slrealtime.internal.parseBlockPath(bp);
        if isempty(indices)
            blockName=bp;
        else
            blockName=extractAfter(bp,indices(end));
        end

        if~isfield(data{i},'outputPortNumber')



            paramName=strrep(data{i}.name,newline,' ');

            this.addParameter([blockName,':',paramName],blockPath,paramName);
        else



            portIndex=data{i}.outputPortNumber;
            signalLabel=data{i}.signalLabel;

            if~isempty(signalLabel)
                displayText=signalLabel;
            else
                displayText=[blockName,':',num2str(portIndex)];
            end

            this.addSignal(displayText,blockPath,portIndex,signalLabel);
        end
    end
end
