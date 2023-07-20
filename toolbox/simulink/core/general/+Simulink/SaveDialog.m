function[filename,unused]=SaveDialog(startname,validate,modal)
























    narginchk(1,3);
    nargoutchk(1,2);



    unused=[];

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
    ext=get_param(0,'ModelFileFormat');
    filename=fullfile(dirname,[bdname,'.',ext]);

    isArchitectureModel=false;

    try
        if Simulink.internal.isArchitectureModel(bdname)
            isArchitectureModel=true;
        end
    catch
    end


    if isArchitectureModel
        filename=fullfile(dirname,[bdname,'.','slx']);
        filters={...
        DAStudio.message('Simulink:editor:SaveAsArchitectureSLX');...
        };
        extensions={...
        DAStudio.message('Simulink:editor:SaveAsFileExtensionSLX');...
        };
    else

        filters={...
        DAStudio.message('Simulink:editor:SaveAsCurrentVersionSLX');...
        DAStudio.message('Simulink:editor:SaveAsCurrentVersionMDL');...
        DAStudio.message('Simulink:editor:SaveAsAllFiles')...
        };
        extensions={...
        DAStudio.message('Simulink:editor:SaveAsFileExtensionSLX');...
        DAStudio.message('Simulink:editor:SaveAsFileExtensionMDL');...
        DAStudio.message('Simulink:editor:SaveAsFileExtensionAll')...
        };
    end

    if strcmp(ext,'mdl')&&~isArchitectureModel

        filters=filters([2,1,3]);
        extensions=extensions([2,1,3]);
    end

    filter=[extensions,filters];
    title=DAStudio.message('Simulink:editor:FileDialogTitle_SaveAs');



    while true
        [f,d]=uiputfile(filter,title,filename);
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

            return;
        else

            filename=[];
            return;
        end
    end
