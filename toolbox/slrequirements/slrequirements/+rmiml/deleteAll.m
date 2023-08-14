function deleteAll(varargin)




    if builtin('_license_checkout','Simulink_Requirements','quiet')
        error(message('Slvnv:reqmgt:setReqs:NoLicense'));
    end



    isFromUI=true;
    if nargin==2
        if ischar(varargin{2})
            if exist(varargin{1},'file')==2
                fPath=rmiut.absolute_path(varargin{1});
            else

                isFromSimulink=rmisl.isSidString(varargin{1});
                if isFromSimulink
                    fPath=varargin{1};
                    if rmisl.isComponentHarness(fPath)
                        fPath=rmiml.harnessToModelRemap(fPath);
                    end
                else
                    fPath='';
                end
            end
            if isempty(fPath)
                return;
            end
            id=varargin{2};
        else
            isFromUI=false;
            [fPath,id]=rmiml.getBookmark(varargin{:});
        end
    else

        [fPath,id]=rmiml.getBookmark();
    end

    if isempty(id)
        error(message('Slvnv:rmiml:NothingToDeleteForThisLocation',fPath));

    else

        if isFromUI


            matchedRange=slreq.idToRange(fPath,id);
            if isempty(matchedRange)||matchedRange(end)==0




                return;
            else
                rmiut.RangeUtils.setSelection(fPath,matchedRange);
            end
            dialogTitle=getString(message('Slvnv:rmiml:DeleteAllLinksTitle'));
            confirmMessage=getString(message('Slvnv:rmiml:DeleteAllLinksQuestion'));
            result=questdlg(confirmMessage,dialogTitle,...
            getString(message('Slvnv:rmi:clearAll:OK')),...
            getString(message('Slvnv:rmi:clearAll:Cancel')),...
            getString(message('Slvnv:rmi:clearAll:Cancel')));
            rmiml.clearSelection(fPath,matchedRange);
            if isempty(result)||strcmp(result,getString(message('Slvnv:rmi:clearAll:Cancel')))
                return;
            end
        end


        rmiml.setReqs([],fPath,id);
    end



end

