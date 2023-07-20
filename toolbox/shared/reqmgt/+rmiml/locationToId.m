function[srcName,id,isNew]=locationToId(shouldCreate,varargin)



    isNew=false;
    isCurrentTarget=false;

    if isempty(varargin)


        isCurrentTarget=true;
        [srcName,selection]=rmiml.getSelection();

    elseif isempty(varargin{1})

        srcName='';
        id='';
        return;

    else
        srcName=varargin{1};
        selection=varargin{2};
    end

    srcName=qualifySrcName(srcName);


    if~rmiml.canLink(srcName)
        srcName='';
        id='';
        return;
    end


    if ischar(selection)
        id=selection;
    else
        [id,isNew]=getIdForLocation(srcName,selection,shouldCreate);
    end





    if isempty(id)&&~shouldCreate
        id=sprintf('%d-%d',selection(1),selection(end));
    elseif isCurrentTarget&&isNew
        rmiml.notifyEditor(srcName,id);
    end
end

function srcName=qualifySrcName(srcName)




    if exist(srcName,'file')==2
        srcName=rmiut.absolute_path(srcName);
    elseif rmisl.isSidString(srcName)


        if rmisl.isComponentHarness(strtok(srcName,':'))
            srcName=rmiml.harnessToModelRemap(srcName);
        end
    else

        pathToMatlabFile=rmiut.cmdToPath(srcName);
        if~isempty(pathToMatlabFile)
            srcName=pathToMatlabFile;
        end
    end
end

function[id,isNew]=getIdForLocation(srcName,selection,shouldCreate)
    [id,isNew]=slreq.getRangeId(srcName,selection,shouldCreate);
    if iscell(id)
        id=id{1};
    end
end
