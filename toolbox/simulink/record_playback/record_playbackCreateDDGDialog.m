function obj=record_playbackCreateDDGDialog(h,className)






    if isempty(className)
        className={get_param(h,'BlockType')};
    end


    obj=rapdlg.(className{1})(h);
end