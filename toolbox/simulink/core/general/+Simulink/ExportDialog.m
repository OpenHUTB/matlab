function[filename,version]=ExportDialog(startname,validate,modal)





























    narginchk(1,3);
    nargoutchk(2,2);

    assert(~isempty(startname));

    if nargin<2
        validate=true;
    end
    if nargin<3
        modal=true;
    end



    [dirname,bdname]=fileparts(startname);
    if isempty(dirname)
        dirname=pwd;
    end



    bdType=get_param(bdname,'BlockDiagramType');


    [filter,versions]=saveas_version.getDialogFilterStrings(bdType);

    title=DAStudio.message('Simulink:editor:FileDialogTitle_ExportToPreviousVersion');


    if strcmp(versions{1}(end-2:end),'SLX')
        file_ext='.slx';
    else
        file_ext='.mdl';
    end
    filename=fullfile(dirname,[bdname,file_ext]);



    while true
        [f,d,idx]=uiputfile(filter,title,filename);
        if ischar(f)
            filename=fullfile(d,f);
            [~,bdname,ext]=fileparts(filename);
            if(validate)
                if isempty(ext)
                    ext=get_param(0,'ModelFileFormat');
                    filename=[filename,'.',ext];%#ok<AGROW> (not really growing)
                elseif~strcmpi(ext,'.mdl')&&~strcmpi(ext,'.slx')

                    id='Simulink:LoadSave:InvalidFileNameExtension';
                    msg=DAStudio.message(id,filename);
                    if modal
                        uiwait(errordlg(...
                        msg,title,'modal'));
                        continue;
                    else
                        DAStudio.error(id,filename);
                    end
                end
                if~isvarname(bdname)

                    id='Simulink:LoadSave:InvalidBlockDiagramName';
                    msg=DAStudio.message(id,bdname);
                    if modal
                        uiwait(errordlg(msg,title,'modal'));
                        continue;
                    else
                        DAStudio.error(id,bdname);
                    end
                elseif strcmpi(bdname,'simulink')

                    id='Simulink:LoadSave:InvalidBlockDiagramNameReserved';
                    msg=DAStudio.message(id,bdname);
                    if modal
                        uiwait(errordlg(msg,title,'modal'));
                        continue;
                    else
                        DAStudio.error(id,bdname);
                    end
                end
            end
            version=versions{idx};

            return;
        else

            filename=[];
            version=[];
            return;
        end
    end
