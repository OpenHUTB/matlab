function exportMatFileUI(UD)








    msg='';


    labels={getString(message('Sigbldr:sigbldr:FileNameColon')),getString(message('Sigbldr:sigbldr:GroupIdxColon'))};
    strtVals={'dataset','1'};
    vals=sigbuilder_modal_edit_dialog('ExporttoMatFileDlg',...
    getString(message('Sigbldr:sigbldr:ExportToMat')),labels,strtVals);

    if iscell(vals)
        try

            matFileName=vals{1};
            grpIdx=vals{2};


            groupIdx=str2num(grpIdx);%#ok<ST2NM>

            if isempty(groupIdx)
                msg=getString(message('sigbldr_api:signalbuilder:NoGroupExists',grpIdx));
            end

            if~isfinite(groupIdx)
                msg=getString(message('sigbldr_api:signalbuilder:InvalidGroupIndex'));
            end

            if any(groupIdx<1)
                msg=getString(message('sigbldr_api:signalbuilder:InvalidGroupIndex'));
            end

            if any(groupIdx>length(UD.dataSet))
                msg=getString(message('sigbldr_api:signalbuilder:InvalidGroupIndex'));
            end

            if~isempty(msg)
                ME=MException('sigbldr_api:signalbuilder:invalidSignalOrGroupIndex','''%s''',msg);
                throw(ME);
            end

            exportMatFile(matFileName,UD,groupIdx,true);

        catch exportError
            errordlg(getString(message('Sigbldr:sigbldr:ExportError',exportError.message)));
        end
    end
