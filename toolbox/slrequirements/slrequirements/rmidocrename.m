function rmidocrename( model, old_doc, new_doc )
%   RMIDOCRENAME - (Not recommended) Update model requirements document paths and file names.
%   RMIDOCRENAME(MODEL_HANDLE, OLD_PATH, NEW_PATH)
%   RMIDOCRENAME(MODEL_NAME, OLD_PATH, NEW_PATH)
%
%   Using rmidocrename is not recommended. Use slreq.LinkSet.updateDocUri 
%   instead.
%
%   RMIDOCRENAME(MODEL_HANDLE, OLD_PATH, NEW_PATH) collectively
%   updates the links from a Simulink(R) model to requirements files whose
%   names or locations have changed. MODEL_HANDLE is a handle to the
%   model that contains links to the files that you have moved or renamed.
%   OLD_PATH is a string that contains the existing file name or path or 
%   a fragment of file name or path.
%   NEW_PATH is a string that contains the new file name, path or fragment.
%
%   RMIDOCRENAME(MODEL_NAME, OLD_PATH, NEW_PATH) updates the
%   links to requirements files associated with MODEL_NAME. You can pass
%   RMIDOCRENAME a model handle or a model name string.
%
%   When using the RMIDOCRENAME function, make sure to enter specific
%   strings for the old document name fragments so that you do not
%   inadvertently modify other links.
%
%   RMIDOCRENAME displays the number of links modified.
%
%   Examples:
%
%       For the current Simulink(R) model, update all links to requirements
%       files whose names contain the string 'project_0220', replacing 
%       with 'project_0221': 
%           rmidocrename(gcs, 'project_0220', 'project_0221');
%       
%       For the model whose handle is 3.0012, update links after all
%       documents were moved from C:\My Documents to D:\Documents
%           rmidocrename(3.0012, 'C:\My Documents', 'D:\Documents');
%
%
%   See also SLREQ.LINKSET.UPDATEDOCURI, RMI, RMITAG

%   Copyright 2009-2018 The MathWorks, Inc.

    if nargin ~= 3  
        error(message('Slvnv:reqmgt:rmidocrename:InvalidArgument'));
    end

    model = convertStringsToChars(model);
    old_doc = convertStringsToChars(old_doc);
    new_doc = convertStringsToChars(new_doc);
    if ~ischar(old_doc) || ~ischar(new_doc)
        error(message('Slvnv:reqmgt:rmidocrename:InvalidArgument'));
    end
    
    try
        modelH = rmisl.getmodelh(model);
    catch Mex 
        error(message('Slvnv:reqmgt:rmidocrename:NoModel', model));
    end
    if ishandle(modelH)
        if ~strcmp(get_param(modelH, 'HasReqInfo'), 'on') 
            % using new infrastructure for "external" models
            [num_objects, modified, total] = slreq.docRename(modelH, old_doc, new_doc);
        else
            % legacy implementation handles "internal" case "old external"
            [num_objects, modified, total] = rmi.docRename(modelH, old_doc, new_doc);
        end
        disp(getString(message('Slvnv:rmidata:map:RmiDocRename', ...
            num2str(num_objects), num2str(modified), num2str(total))));
    else
        error(message('Slvnv:reqmgt:rmidocrename:ResolveModelFailed', model));
    end

end


