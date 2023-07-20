function[edittimeJSON,edittimeXML]=setEditTimeCheckingBehavior(filePath,varargin)










    writeToDisk=true;

    if nargin>1
        writeToDisk=varargin{1};
    end

    jsonString=getJSONStringFromFilePath(filePath);
    jsonData=jsondecode(jsonString);
    if~isfield(jsonData,'Tree')
        checkData=jsonData;
        jsonData=[];
        jsonData.Tree=checkData;
    end
    jsonData_Tree=jsonData.Tree;

    edittimeJSONData={};
    xmlSummary='';
    checkIdMap=containers.Map;
    for i=1:numel(jsonData_Tree)
        if iscell(jsonData_Tree)
            jsonElement=jsonData_Tree{i};
        else
            jsonElement=jsonData_Tree(i);
        end

        if isfield(jsonElement,'isedittime')&&~jsonElement.isedittime
            continue;
        end

        if~jsonElement.check
            continue;
        end

        if checkIdMap.isKey(jsonElement.checkid)
            continue;
        end

        checkIdMap(jsonElement.checkid)=true;

        if jsonElement.isblockconstraint
            constraintXML=Advisor.authoring.utils.getXMLDataFromCheck(jsonElement.checkid,[]);
            jsonElement.ConstraintXML=constraintXML;
            xmlSummary=[xmlSummary,constraintXML];
        end

        edittimeJSONData{end+1}=jsonElement;

    end

    edittimeJSON=jsonencode(edittimeJSONData,'PrettyPrint',true);
    trimmedString=strtrim(edittimeJSON);
    if length(edittimeJSON)==1&&trimmedString(1)=='{'
        edittimeJSON=['[',edittimeJSON,']'];
    end

    jsonData.Tree=edittimeJSONData;
    edittimeConfiguration=jsonencode(jsonData,'PrettyPrint',true);

    shippingConstraints=getShippingConstraintXML();
    edittimeXML=strrep(shippingConstraints,...
    sprintf('</CheckCellArray>\n</MAConfiguration>'),...
    [xmlSummary,...
    sprintf('</CheckCellArray>\n</MAConfiguration>')]);

    if writeToDisk
        writeEditConfiguration(edittimeConfiguration)
        writeConstraintXML(edittimeXML)
        modeladvisorprivate('modeladvisorutil2','refreshAdvisorConfigurationForEditTime');
    end

end



function shippingConstraints=getShippingConstraintXML()
    shippingConstraints=fileread(fullfile(matlabroot,'toolbox',...
    'simulink','simulink','modeladvisor','resources',...
    'blockconstraintscustomization.xml'));
end

function writeEditConfiguration(configuration)
    edittimecheckcustomizationFileName=fullfile(prefdir,'edittimecheckcustomization.json');
    fid=fopen(edittimecheckcustomizationFileName,'wt','n','UTF-8');
    fwrite(fid,configuration,'char');
    fclose(fid);
end

function writeConstraintXML(edittimeXML)
    blockconstraintcheckcustomizationFileName=fullfile(prefdir,'blockconstraintscustomization.xml');
    fid=fopen(blockconstraintcheckcustomizationFileName,'wt','n','UTF-8');
    fwrite(fid,edittimeXML,'char');
    fclose(fid);
end

function jsonString=getJSONStringFromFilePath(filePath)
    [~,~,ext]=fileparts(filePath);
    if strcmp(ext,'.json')
        jsonString=fileread(filePath);
    else
        load(filePath);%#ok<LOAD> % try loading jsonString
        if exist('jsonString','var')
        else

            maObj=Simulink.ModelAdvisor;
            am=Advisor.Manager.getInstance;
            am.updateCacheIfNeeded;
            maObj.loadConfiguration(filePath);
            jsonString=Advisor.Utils.exportJSON(maObj,'MACE');
        end
    end
end