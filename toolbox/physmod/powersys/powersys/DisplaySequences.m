function varargout=DisplaySequences(varargin)






    gui_Singleton=1;
    gui_State=struct('gui_Name',mfilename,...
    'gui_Singleton',gui_Singleton,...
    'gui_OpeningFcn',@DisplaySequences_OpeningFcn,...
    'gui_OutputFcn',@DisplaySequences_OutputFcn,...
    'gui_LayoutFcn',[],...
    'gui_Callback',[]);
    if nargin&&ischar(varargin{1})
        gui_State.gui_Callback=str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}]=gui_mainfcn(gui_State,varargin{:});
    else
        gui_mainfcn(gui_State,varargin{:});
    end




    function DisplaySequences_OpeningFcn(hObject,eventdata,handles,varargin)%#ok



        handles.output=hObject;

        guidata(hObject,handles);
        R=varargin{1};
        Frequency=varargin{2};
        GR=varargin{3};
        Units=varargin{4};
        Comments=varargin{5};
        Geometry=varargin{6};
        Conductors=varargin{7};
        NPhaseBundle=varargin{8};
        NGroundBundle=varargin{9};
        Texte=TextToDisplay(R,Frequency,GR);
        if isempty(Geometry)
            set(handles.Report,'Enable','off');
        end
        set(handles.listbox1,'String',Texte,'UserData',{R,Frequency,GR,Units,Comments,Geometry,Conductors,NPhaseBundle,NGroundBundle});




        function varargout=DisplaySequences_OutputFcn(hObject,eventdata,handles)%#ok

            varargout{1}=handles.output;



            function ToWorkspace_Callback(hObject,eventdata,handles)%#ok

                UserData=get(handles.listbox1,'UserData');
                R=UserData{1};
                assignin('base','R_matrix',R{1});
                assignin('base','L_matrix',R{2});
                assignin('base','C_matrix',R{3});
                disp('R_matrix = ');disp(R{1});
                disp('L_matrix = ');disp(R{2});
                disp('C_matrix = ');disp(R{3});
                if~isempty(R{4})
                    assignin('base','R10',R{4});
                    assignin('base','L10',R{5});
                    assignin('base','C10',R{6});
                    disp('R10 = ');disp(R{4});
                    disp('L10 = ');disp(R{5});
                    disp('C10 = ');disp(R{6});
                end



                function Close_Callback(hObject,eventdata,handles)%#ok

                    close(handles.figure1);


                    function SelectedBlock_Callback(hObject,eventdata,handles)%#ok

                        block=gcb;
                        if~isempty(block)
                            MaskType=get_param(block,'MaskType');
                            switch MaskType
                            case{'Distributed Parameters Line','Pi Section Line','Three-Phase PI Section Line','Pi Section Cable'}
                                set(handles.BlockName,'String',strrep(gcb,char(10),' '));
                                BlockName_Callback(handles.BlockName,[],handles);
                            end
                        end


                        function matrices_Callback(hObject,eventdata,handles)%#ok

                            UserData=get(handles.listbox1,'UserData');
                            R=UserData{1};
                            F=UserData{2};
                            Phases=size(R{1},1);
                            block=get(handles.BlockName,'String');
                            if~isempty(block)
                                MaskType=get_param(block,'MaskType');
                                set_param(block,'Resistance',mat2str(R{1},5),'Inductance',mat2str(R{2},5),'Capacitance',mat2str(R{3},5),'Frequency',mat2str(F));
                                if strcmp('Distributed Parameters Line',MaskType)
                                    set_param(block,'Phases',mat2str(Phases));
                                end
                            end





                            function sequences_Callback(hObject,eventdata,handles)%#ok





                                UserData=get(handles.listbox1,'UserData');
                                R=UserData{1};
                                F=mat2str(UserData{2});

                                Phases=size(R{1},1);
                                block=get(handles.BlockName,'String');
                                ThreePhasePISectionLine=strcmp(get_param(block,'MaskType'),'Three-Phase PI Section Line');
                                PISectionLine=strcmp(get_param(block,'MaskType'),'Pi Section Line');
                                PISectionCable=strcmp(get_param(block,'MaskType'),'Pi Section Cable');
                                DistributedParametersLine=strcmp(get_param(block,'MaskType'),'Distributed Parameters Line');
                                if Phases==3
                                    if ThreePhasePISectionLine
                                        set_param(block,'Frequency',F,'Resistances',mat2str(R{4},5),'Inductances',mat2str(R{5},5),'Capacitances',mat2str(R{6},5));
                                    else
                                        set_param(block,'Frequency',F,'Resistance',mat2str(R{4},5),'Inductance',mat2str(R{5},5),'Capacitance',mat2str(R{6},5));
                                    end
                                end
                                if Phases==6
                                    UserData2=get(handles.BlockName,'UserData');
                                    R6=UserData2{1};
                                    L6=UserData2{2};
                                    C6=UserData2{3};
                                    if ThreePhasePISectionLine
                                        set_param(block,'Frequency',F,'Resistances',mat2str(R6,5),'Inductances',mat2str(L6,5),'Capacitances',mat2str(C6,5));
                                    else
                                        set_param(block,'Frequency',F,'Resistance',mat2str(R6,5),'Inductance',mat2str(L6,5),'Capacitance',mat2str(C6,5));
                                    end
                                end
                                if PISectionLine
                                    set_param(block,'Frequency',F,'Resistance',mat2str(R{1},5),'Inductance',mat2str(R{2},5),'Capacitance',mat2str(R{3},5));
                                end
                                if PISectionCable
                                    set_param(block,'Resistance',mat2str(R{1},5),'Inductance',mat2str(R{2},5),'Capacitance',mat2str(R{3},5));
                                end
                                if DistributedParametersLine
                                    set_param(block,'Phases',mat2str(Phases));
                                end




                                function BlockName_CreateFcn(hObject,eventdata,handles)%#ok






                                    if ispc
                                        set(hObject,'BackgroundColor','white');
                                    else
                                        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
                                    end



                                    function BlockName_Callback(hObject,eventdata,handles)%#ok




                                        UserData=get(handles.listbox1,'UserData');
                                        R=UserData{1};
                                        Frequency=UserData{2};%#ok
                                        GR=UserData{3};%#ok
                                        R6=[];
                                        L6=[];
                                        C6=[];
                                        Phases=size(R{1},1);
                                        BlockName=get(hObject,'String');
                                        try
                                            MaskType=get_param(BlockName,'MaskType');
                                        catch ME
                                            Erreur.message=ME.message;
                                            Erreur.identifier='SpecializedPowerSystems:PowerLineParam:DisplaySequences';
                                            psberror(Erreur.message,Erreur.identifier);
                                            return
                                        end
                                        switch MaskType
                                        case{'Pi Section Line','Pi Section Cable'}
                                            set(handles.sequences,'Enable','off');
                                            if Phases==1
                                                set(handles.sequences,'Enable','on');
                                                set(handles.matrices,'Enable','off');
                                            else
                                                set(handles.matrices,'Enable','on');
                                            end
                                        case 'Three-Phase PI Section Line'
                                            set(handles.matrices,'Enable','off');
                                            if Phases==3
                                                set(handles.sequences,'Enable','on');
                                            else
                                                set(handles.sequences,'Enable','off');
                                            end
                                        case 'Distributed Parameters Line'
                                            set(handles.matrices,'Enable','on');
                                            if Phases==3
                                                set(handles.sequences,'Enable','on');
                                            elseif Phases==6

                                                Res=R{4};
                                                L=R{5};
                                                C=R{6};
                                                if abs(Res(1)-Res(4))<1e-4&&abs(Res(2)-Res(5))<1e-4&&abs(L(1)-L(4))<1e-4&&abs(L(2)-L(5))<1e-4&&abs(C(1)-C(4))<1e-4&&abs(C(2)-C(5))<1e-4
                                                    R6=Res(1:3);
                                                    L6=L(1:3);
                                                    C6=C(1:3);
                                                    set(handles.sequences,'Enable','on');
                                                else
                                                    set(handles.sequences,'Enable','off');
                                                end
                                            else
                                                set(handles.sequences,'Enable','off');
                                            end
                                        otherwise
                                            set(hObject,'String','');
                                        end
                                        set(handles.BlockName,'UserData',{R6,L6,C6});



                                        function Report_Callback(hObject,eventdata,handles)%#ok




                                            UserData=get(handles.listbox1,'UserData');
                                            R=UserData{1};
                                            Frequency=UserData{2};
                                            GR=UserData{3};
                                            Units=UserData{4};
                                            Comments=UserData{5};
                                            Geometry=UserData{6};
                                            Conductors=UserData{7};
                                            NPhaseBundle=UserData{8};
                                            NGroundBundle=UserData{9};

                                            [FileName,Pathname]=uiputfile('Lineparameters.rep','Save the report file');



                                            if~FileName,
                                                return
                                            end

                                            WB=waitbar(0,'Generating a report ...');
                                            fid=fopen([Pathname,FileName],'w+');

                                            if fid==-1
                                                return
                                            end


                                            fprintf(fid,'Power_lineparam Report.\n');
                                            fprintf(fid,'%s\n\n',datestr(datenum(clock),0));


                                            fprintf(fid,'COMMENTS:\n\n');
                                            for i=1:size(Comments,1)
                                                fprintf(fid,'%s\n',Comments(i,:));
                                            end

                                            fprintf(fid,'\n\nLINE GEOMETRY:');
                                            fprintf(fid,'\n\nFrequency (Hz): %3.2f',Frequency);
                                            fprintf(fid,'\nGround resistivity (ohm.m): %1.3f',GR);
                                            fprintf(fid,'\nNumber of phase conductors (bundles): %i',NPhaseBundle);
                                            fprintf(fid,'\nNumber of ground wires (bundles): %i',NGroundBundle);

                                            fprintf(fid,'\n\nConductor  Phase      X         Ytower      Ymin     Conductor');
                                            if Units==1
                                                fprintf(fid,'\n(bundle)   number    (m)         (m)         (m)     (bundle)type');
                                            else
                                                fprintf(fid,'\n(bundle)   number    ('')         ('')         ('')     (bundle)type');
                                            end
                                            fprintf(fid,'\n-----------------------------------------------------------------');
                                            for i=1:length(Geometry.X)
                                                X=Geometry.X(i);
                                                Ytower=Geometry.Ytower(i);
                                                Ymin=Geometry.Ymin(i);
                                                if Units==2
                                                    [d,d,d,d,d,d,X,Ytower,Ymin]=ConvertLineData(1,1,1,1,1,1,X,Ytower,Geometry.Ymin(i),Frequency,'english');%#ok
                                                end
                                                fprintf(fid,'\n\t%i\t\t %i\t\t%4.3f\t\t%4.3f\t\t%4.3f\t\t%i',i,Geometry.PhaseNumber(i),X,Ytower,Ymin,Geometry.ConductorType(i));
                                            end
                                            fprintf(fid,'\n-----------------------------------------------------------------');




                                            fprintf(fid,'\n\n\nCONDUCTOR AND BUNDLE CHARACTERISTICS:');

                                            fprintf(fid,'\n\nConductor   Conductor   Conductor   Conductor   Conductor DC  Conductor   Number    Bundle    Angle of');
                                            fprintf(fid,'\n(bundle)    Outside     T/D         GMR         resistance    relative    of        diameter  conductor');
                                            if Units==1
                                                fprintf(fid,'\nType        Diam.(cm)   ratio       (cm)        (Ohms/km)     permeab.    conduct.  (cm)      one (deg.)');
                                            else
                                                fprintf(fid,'\nType        Diam.(")    ratio       (")         (Ohms/mi)     permeab.    conduct.  (")       one (deg.)');
                                            end
                                            fprintf(fid,'\n-------------------------------------------------------------------------------------------------------\n');
                                            for i=1:length(Conductors.Res)
                                                Diameter=Conductors.Diameter(i);
                                                GMR=Conductors.GMR(i);
                                                DCresistance=Conductors.Res(i);
                                                BundleDiameter=Conductors.BundleDiameter(i);
                                                if Units==2
                                                    [DCresistance,Diameter,BundleDiameter,GMR]=ConvertLineData(DCresistance,Diameter,BundleDiameter,GMR,1,1,1,1,1,Frequency,'english');
                                                end
                                                fprintf(fid,'\t%i\t    %4.3f\t\t%4.3f\t\t%4.3f\t\t%4.3f\t\t  %i\t\t\t  %i\t\t\t%4.3f\t  %4.2f',i,100*Diameter,Conductors.ThickRatio(i),100*GMR,DCresistance,Conductors.Mur(i),Conductors.Nconductors(i),100*BundleDiameter,Conductors.AngleConductor1(i));
                                                fprintf(fid,'\n');
                                            end
                                            fprintf(fid,'-------------------------------------------------------------------------------------------------------\n');

                                            fprintf(fid,'\n\nR, L, AND C LINE PARAMETERS:');
                                            fprintf(fid,'\n\nResistance matrix R_matrix (ohm/km):\n\n');
                                            for i=1:length(R{1})
                                                for j=1:length(R{1})
                                                    fprintf(fid,'%1.4f  ',R{1}(i,j));
                                                end
                                                fprintf(fid,'\n');
                                            end
                                            fprintf(fid,'\nInductance matrix L_matrix (H/km):\n\n');
                                            for i=1:length(R{2})
                                                for j=1:length(R{2})
                                                    fprintf(fid,'%1.4e  ',R{2}(i,j));
                                                end
                                                fprintf(fid,'\n');
                                            end
                                            fprintf(fid,'\nCapacitance matrix C_matrix (F/km):\n\n');
                                            for i=1:length(R{3})
                                                for j=1:length(R{3})
                                                    fprintf(fid,'%1.4e  ',R{3}(i,j));
                                                end
                                                fprintf(fid,'\n');
                                            end

                                            if~isempty(R{4})
                                                if size(R{4},2)==2;
                                                    fprintf(fid,'\nPositive- & zero- sequence resistance [R1 Ro] (ohm/km):\n\n[ %1.4f , %1.4f ]',R{4}(1),R{4}(2));
                                                    fprintf(fid,'\n\nPositive- & zero- sequence inductance [L1 Lo] (H/km):\n\n[ %1.4e , %1.4e ]',R{5}(1),R{5}(2));
                                                    fprintf(fid,'\n\nPositive- & zero- sequence capacitance [C1 Co] (F/km):\n\n[ %1.4e , %1.4e ]',R{6}(1),R{6}(2));
                                                elseif size(R{4},2)==5;
                                                    fprintf(fid,'\nPositive-, zero- & mutual zero-sequence resistances of circuits 1 and 2.\nR10 = [R1_1  Ro_1 Rom R1_2 Ro_2] (ohm/km):\n\n[ %1.4f , %1.4f , %1.4f , %1.4f , %1.4f ]',R{4}(1),R{4}(2),R{4}(3),R{4}(4),R{4}(5));
                                                    fprintf(fid,'\n\nPositive-, zero- & mutual zero-sequence inductances of circuits 1 and 2.\nL10 = [L1_1  Lo_1 Lom L1_2 Lo_2] (H/km):\n\n[ %1.4e , %1.4e , %1.4e , %1.4e , %1.4e ]',R{5}(1),R{5}(2),R{5}(3),R{5}(4),R{5}(5));
                                                    fprintf(fid,'\n\nPositive-, zero- & mutual zero-sequence capacitances of circuits 1 and 2.\nC10 = [C1_1  Co_1 Com C1_2 Co_2] (F/km):\n\n[ %1.4e , %1.4e , %1.4e , %1.4e , %1.4e] ',R{6}(1),R{6}(2),R{6}(3),R{6}(4),R{6}(5));
                                                else
                                                    fprintf(fid,'\nR:');
                                                    fprintf(fid,'\nL:');
                                                    fprintf(fid,'\nC:');
                                                end
                                            end

                                            waitbar(1,WB);
                                            fclose(fid);
                                            close(WB);
                                            eval(['edit ',FileName])





                                            function Texte=TextToDisplay(R,Frequency,GR);%#ok

                                                if size(R{4},2)==2;
                                                    TR={'Positive- & zero- sequence resistance.','R10 = [R1  Ro ]  (ohm/km):'};
                                                    TL={'Positive- & zero- sequence inductance.','L10 = [L1  Lo ]  (H/km):'};
                                                    TC={'Positive- & zero- sequence capacitance.','C10 = [C1  Co ]  (F/km):'};
                                                elseif size(R{4},2)==5;
                                                    TR={'Positive-, zero- & mutual zero-sequence resistances of circuits 1 and 2.','R10 = [R1_1  Ro_1 Rom R1_2 Ro_2] (ohm/km):'};
                                                    TL={'Positive-, zero- & mutual zero-sequence inductances of circuits 1 and 2.','L10 = [L1_1  Lo_1 Lom L1_2 Lo_2] (H/km):'};
                                                    TC={'Positive-, zero- & mutual zero-sequence capacitances of circuits 1 and 2.','C10 = [C1_1  Co_1 Com C1_2 Co_2] (F/km):'};
                                                else
                                                    TR={'R:',''};
                                                    TL={'L:',''};
                                                    TC={'C:',''};
                                                end
                                                if isempty(R{4})

                                                    Texte={'Frequency (Hz): ';num2str(Frequency);' ';
                                                    'Ground resistivity (ohm.m): ';num2str(GR);' ';
                                                    'Resistance matrix R_matrix (ohm/km):';' ';num2str(R{1},5);' ';
                                                    'Inductance matrix L_matrix (H/km):';' ';num2str(R{2},5);' ';
                                                    'Capacitance matrix C_matrix (F/km):';' ';num2str(R{3},5)};
                                                else

                                                    Texte={'Frequency (Hz): ';num2str(Frequency);' ';
                                                    'Ground resistivity (ohm.m): ';num2str(GR);' ';
                                                    'Resistance matrix R_matrix (ohm/km):';' ';num2str(R{1},5);' ';
                                                    'Inductance matrix L_matrix (H/km):';' ';num2str(R{2},5);' ';
                                                    'Capacitance matrix C_matrix (F/km):';' ';num2str(R{3},5);' ';' ';' ';
                                                    TR{1};TR{2};' ';mat2str(R{4},5);' ';' ';
                                                    TL{1};TL{2};' ';mat2str(R{5},5);' ';' ';
                                                    TC{1};TC{2};' ';mat2str(R{6},5)};

                                                end
