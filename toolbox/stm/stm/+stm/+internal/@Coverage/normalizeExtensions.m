


function files=normalizeExtensions(files)
    [~,names,exts]=slfileparts(string(files));
    files=names+exts;
    files=files(files.strlength>0);
    idx=files.endsWith('.cvf','IgnoreCase',true);
    files(~idx)=files(~idx)+".cvf";
end
