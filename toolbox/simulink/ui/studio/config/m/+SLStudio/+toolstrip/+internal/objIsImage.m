



function isImage=objIsImage(obj)
    isImage=false;
    note=get_param(obj.handle,'Object');
    if isa(note,'Simulink.Annotation')&&~isempty(note.imagePath)
        isImage=true;
    end
end