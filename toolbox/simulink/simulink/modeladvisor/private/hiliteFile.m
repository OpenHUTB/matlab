function hiliteFile(varargin)







    last_file=hilitedSystem;

    if(~isempty(last_file))
        try
            hilite_system(last_file,'none');
        catch %#ok<CTCH>
            last_file={};
            hilitedSystem(last_file);
        end
    end
    try
        last_file=modeladvisorprivate('HTMLjsencode',varargin{1},'decode');
        idx=strfind(last_file,'.m');
        if~exist(last_file(1:idx(end)+1),'file')
            warndlg(DAStudio.message('ModelAdvisor:engine:FileNotFound'));
            return;
        end
        fName=last_file(1:idx(end)+1);
        eObj=matlab.desktop.editor.openDocument(fName);
        idxNumbers=last_file(idx(end)+3:end);
        [idxNum,idxNumEnd]=extractIndexNumber(idxNumbers);

        mt=mtree(fName,'-com','-cell','-file','-comments');
        [line1,position1]=mt.pos2lc(idxNum);
        [line2,position2]=mt.pos2lc(idxNumEnd);

        eObj.Selection=[line1,position1,line2,position2+1];

    catch E %#ok<CTCH>
        if strcmp(E.identifier,'MATLAB:Editor:Document:PartialPath')

            edit(last_file(1:idx(1)+1));
        end
        return;
    end

    function[idxNum,idxNumEnd]=extractIndexNumber(idxNumbers)
        idx=strsplit(idxNumbers,'-');
        idxNum=str2double(idx{1});
        idxNumEnd=str2double(idx{2});
        if~isnumeric(idxNum)
            idxNum=[];
        end
        if~isnumeric(idxNumEnd)
            idxNumEnd=[];
        end