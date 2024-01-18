function[yesno,mdlName]=isSidString(in,doLoad)

    in=convertStringsToChars(in);

    yesno=false;
    mdlName='';
    if ischar(in)
        colonsIdx=find(in==':');
        if~isempty(colonsIdx)&&colonsIdx(1)>2
            possibleMdlName=in(1:colonsIdx(1)-1);
            if exist(possibleMdlName,'file')==4
                mdlName=possibleMdlName;
                yesno=true;
                if nargin>1&&doLoad
                    try
                        load_system(possibleMdlName);
                    catch ex %#ok<NASGU>
                        mdlName=['failed to load "',possibleMdlName,'"'];
                    end
                end
            end
        end
    end
end
