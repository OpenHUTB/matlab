function result=save(varargin)




    if nargin==0


        fPath=matlab.desktop.editor.getActiveFilename();
        if isempty(fPath)
            result=getString(message('Slvnv:rmiml:NoFileIsOpen'));
            fprintf(1,'rmiml.save(): %s\n',result);
        else

            result=saveMatlabFile(fPath,true);
        end

    else
        [varargin{:}]=convertStringsToChars(varargin{:});

        srcName=varargin{1};

        [isEml,mdlName]=rmisl.isSidString(srcName);
        if isEml
            result=saveSimulinkFile(mdlName,false);
        else

            if exist(srcName,'file')~=2
                error(['Missing file: ',srcName]);
            end
            fPath=rmiut.absolute_path(srcName);
            if nargin>1
                newFileName=varargin{2};


                linkSet=slreq.data.ReqData.getInstance.getLinkSet(fPath);
                if isempty(linkSet)
                    result=false;
                    return;
                else
                    linkSet.moveArtifact(newFileName);
                end
                fPath=newFileName;
            end
            result=saveMatlabFile(fPath,false);
        end
    end
end

function result=saveMatlabFile(fPath,verbal)
    try
        linkSet=slreq.data.ReqData.getInstance.getLinkSet(fPath);
        if~isempty(linkSet)










            mlData=rmiml.RmiMlData.getInstance;
            mlData.clearMethodPosCache(fPath);

            if linkSet.dirty
                linkSet.save();
            end











            munitData=rmiml.RmiMUnitData.getInstance;
            munitData.clearCacheEntry(fPath);
        end
        result='success';
    catch ex
        result=ex.message;
        if verbal
            disp(getString(message('Slvnv:rmiml:FailedToSave',fPath,result)));
        end
    end
end

function result=saveSimulinkFile(mdlName,verbal)
    try
        modelFile=get_param(mdlName,'FileName');
        linkSet=slreq.data.ReqData.getInstance.getLinkSet(modelFile);
        if~isempty(linkSet)
            linkSet.save();
        end
        result='success';
    catch ex
        result=ex.message;
        if verbal
            fprintf(1,'rmiml.save(): Failed to save RMI data for %s:\n %s\n',mdlName,result);
        end
    end
end


