function dialogCallback(this,hDlg,tag,action)




    src=this.FPGAProperties;

    switch action



    case[tag,'browseForProjectFolder']
        directoryname=uigetdir('',l_GetUIString('browseForProjectFolder','_Title'));
        if~isequal(directoryname,0)
            set(src,'FPGAProjectFolder',directoryname);
        end





    case[tag,'browseForUserFiles']
        key='browseForUserFiles';
        [filename,pathname]=uigetfile(...
        {'*.vhd;*.v;*.ucf;',l_GetUIString(key,'_Description1');...
        '*.*',l_GetUIString(key,'_Description2')},...
        l_GetUIString(key,'_Title'),...
        'MultiSelect','on');
        if~isequal(filename,0)&&~isequal(pathname,0)
            str=strcat(pathname,filename);
            if iscell(str)


                str=sprintf(['%s',char(10)],str{:});
            end


            str=[src.UserFPGASourceFiles,char(10),str];

            str=regexprep(str,[char(10),'+'],char(10));
            str=regexprep(str,['^',char(10),'|',char(10),'$'],'');

            set(src,'UserFPGASourceFiles',str);
        end



    case[tag,'browseForExistingProject']
        key='browseForExistingProject';
        [filename,pathname]=uigetfile(...
        {'*.xise',l_GetUIString(key,'_Description1');...
        '*.*',l_GetUIString(key,'_Description2')},...
        l_GetUIString(key,'_Title'));
        if~isequal(filename,0)&&~isequal(pathname,0)
            set(src,'ExistingFPGAProjectPath',[pathname,filename]);
        end



    case[tag,'browseForUsrpSource']
        directoryname=uigetdir('',l_GetUIString('browseForUsrpSource','_Title'));
        if~isequal(directoryname,0)
            set(src,'USRPFPGASourceFolder',directoryname);
        end

    end


    function str=l_GetUIString(key,postfix)
        str=DAStudio.message(['EDALink:FPGAUI:',key,postfix]);

