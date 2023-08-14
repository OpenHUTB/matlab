function result=getAll(varargin)








    result={};

    if nargin==0

        return;
    end

    if islogical(varargin{end})



        getLineNumbers=varargin{end};
        lastArg=nargin-1;
    else
        getLineNumbers=true;
        lastArg=nargin;
    end

    src=varargin{1};



    if rmisl.isSidString(src)&&rmisl.isComponentHarness(src)
        src=rmiml.harnessToModelRemap(src);
    end



    if nargin==1
        [canLink,fKey]=rmiml.canLink(src);
        if~canLink
            return;
        end



        if rmisl.isSidString(fKey)
            artifactPath=get_param(strtok(fKey,':'),'FileName');
        else
            artifactPath=fKey;
        end
        if~slreq.utils.loadLinkSet(artifactPath,false)
            return;
        end
    end


    result=slreq.utils.getRangesAndLabels(src,varargin{2:lastArg});



    if~isempty(result)&&getLineNumbers


        rangeHelper=slreq.mleditor.ReqPluginHelper.getInstance();
        result(:,2)=rangeHelper.charPositionToLineNumber(src,result(:,2));
        result(:,3)=rangeHelper.charPositionToLineNumber(src,result(:,3));
    end

end

