function[SPS,StateVarNames,SourceNames,OutputNames]=getABCDspid(SPS)




















    TrimNoiseValue=1e-13;

    Erreur.identifier='SimscapePowerSystemsST:Compiler:StateSpace';



    if SPS.PowerguiInfo.DisplayEquations
        fprintf('\nCircuit differential equations of ''%s'' model.\n\n',SPS.circuit)
    end



    Mg=SPS.MgNotRed;
    MgColNames=SPS.MgColNamesNotRed;
    nb=SPS.Mg_nbNotRed;
    [nline,ncol]=size(Mg);

    nStates=nb.x;
    nOutputs=nb.y;
    nSwitches=nb.s;
    nSources=nb.u;


    State1=nStates+nOutputs+2*nSwitches+1;

    idxColStates=nStates+nOutputs+2*nSwitches+1:ncol-nSources;



    nDependentStates=0;
    LineStateDep=[];

    for iline=1:nline
        if all(Mg(iline,1:nStates+nOutputs+2*nSwitches)==0)&&all(Mg(iline,2*nStates+nOutputs+2*nSwitches+1:ncol)==0)
            nDependentStates=nDependentStates+1;
            LineStateDep(nDependentStates)=iline;%#ok
        end
    end



    if SPS.PowerguiInfo.DisplayEquations&&nDependentStates==0
        if nStates==1
            fprintf('1 state variable:\n')
        else
            fprintf('%d state variables:\n',nStates)
        end
        for i=1:nStates
            sn=['x',num2str(i),''];
            fprintf(' %-4s =  ''%s'';\n',sn,MgColNames{idxColStates(i)})
        end
    end

    MgColNames1=MgColNames;



    if nDependentStates>0




        idxDependentStates=zeros(1,nDependentStates);
        MatStateDependency=Mg(LineStateDep,idxColStates);
        MatStateDependency=rref_mod(MatStateDependency);

        for i=1:nDependentStates
            n=find(MatStateDependency(i,:)~=0);
            idxDependentStates(i)=n(1);
        end

        idxIndependentStates=1:nStates;
        idxIndependentStates(idxDependentStates)=0;
        idxIndependentStates=idxIndependentStates(idxIndependentStates~=0);


        if SPS.PowerguiInfo.DisplayEquations

            fprintf('State variables:\n')

            if nDependentStates==1
                fprintf('\nDependent state:\n')
            else
                fprintf('\nDependent states:\n')
            end
            for i=1:nDependentStates
                ColumnToSelect=find(MatStateDependency(i,:)~=0);
                for j=ColumnToSelect
                    if j==ColumnToSelect(1)
                        coef=MatStateDependency(i,j);
                        str=sprintf(' ');
                    elseif j==ColumnToSelect(2)
                        str=[str,'=  '];%#ok mlint.
                        coef=-MatStateDependency(i,j);
                    else
                        coef=-MatStateDependency(i,j);
                    end
                    icol=nStates+nOutputs+2*nSwitches+j;
                    if coef==1,
                        if j==ColumnToSelect(1)||j==ColumnToSelect(2)
                            str1=sprintf('%s ',char(MgColNames(icol)));

                        else
                            str1=sprintf('+ %s ',char(MgColNames(icol)));

                        end
                    elseif coef==-1
                        str1=sprintf('- %s ',char(MgColNames(icol)));

                    elseif coef>0
                        str1=sprintf('+ %g*%s ',coef,char(MgColNames(icol)));

                    else
                        str1=sprintf('- %g*%s ',abs(coef),char(MgColNames(icol)));

                    end
                    str=[str,str1];%#ok
                end
                fprintf('%s\n',str)
            end
        end


        Mg=Mg(1:nline,:);
        MgRed=Mg;
        ilineMatStateDependency=0;

        for i=idxDependentStates


            ilineMatStateDependency=ilineMatStateDependency+1;
            nlineDep=find(Mg(:,i)~=0);
            for iline=nlineDep'
                MgRed(iline,1:nStates)=MgRed(iline,1:nStates)-...
                MgRed(iline,i)*MatStateDependency(ilineMatStateDependency,:)/MatStateDependency(ilineMatStateDependency,i);
            end

            nlineDep=find(Mg(:,i+nStates+nOutputs+2*nSwitches)~=0);
            for iline=nlineDep'
                MgRed(iline,(1:nStates)+nStates+nOutputs+2*nSwitches)=...
                MgRed(iline,(1:nStates)+nStates+nOutputs+2*nSwitches)-...
                MgRed(iline,i+nStates+nOutputs+2*nSwitches)*MatStateDependency(ilineMatStateDependency,:)/MatStateDependency(ilineMatStateDependency,i);
            end
        end





        LineToSelect=[];
        LineToDelete=[];
        for iline=1:nline
            if~all(MgRed(iline,:)==0)
                LineToSelect=[LineToSelect,iline];%#ok
            else
                LineToDelete=[LineToDelete,iline];%#ok
            end
        end


        ColumnToSelect=[idxIndependentStates,idxIndependentStates+nStates+nOutputs+2*nSwitches];

        ColumnToSelect=[ColumnToSelect,nStates+1:nStates+nOutputs+2*nSwitches];

        ColumnToSelect=[ColumnToSelect,ncol-nSources+1:ncol];
        ColumnToSelect=sort(ColumnToSelect);

        MgRed=MgRed(LineToSelect,ColumnToSelect);



        if length(LineToDelete)==length(LineStateDep)
            if~all(LineToDelete==LineStateDep)
                fprintf('The ''LineToDelete vector'' of lines to delete (1 line per dependent state):\n')
                disp(LineToDelete);
                fprintf('does not correspond to the ''LineStateDep'' vector of Mg lines where state dependencies have been found:\n')
                disp(LineStateDep);
                Erreur.message=sprintf('Error during reduction of the %d dependent states',nDependentStates);
                psberror(Erreur);
            end
        else
            fprintf('The number of dependent states (%d) does not correspond to the number of Mg lines to be deleted\n',...
            nDependentStates)
            disp(LineStateDep)
            disp(LineToDelete)
            Erreur.message=sprintf('Error during reduction of the %d dependent states',nDependentStates);
            psberror(Erreur);
        end


        nb.x=nb.x-nDependentStates;
        MgColNames=MgColNames(ColumnToSelect);


        nStatesRed=nStates-nDependentStates;
        StateVarNames=MgColNames(nStatesRed+nOutputs+2*nSwitches+1:2*nStatesRed+nOutputs+2*nSwitches);
        StateVarNamesRed=MgColNames1(nStates+nOutputs+2*nSwitches+idxDependentStates);
        StateVarNames=[StateVarNames,StateVarNamesRed]';
        nStates=nStates-nDependentStates;


        MatStateDependency=MatStateDependency(:,[idxIndependentStates,idxDependentStates]);


        if SPS.PowerguiInfo.DisplayEquations
            fprintf('\nIndependent states:\n');
            for i=1:nStates
                sn=['x',num2str(i),''];
                fprintf(' %-4s =  ''%s'';\n',sn,StateVarNames{i})
            end
        end
    else
        MgRed=Mg;
        StateVarNames=MgColNames(nStates+nOutputs+2*nSwitches+1:2*nStates+nOutputs+2*nSwitches);
        MatStateDependency=zeros(0,nStates);
    end

    [nline,ncol]=size(MgRed);


    SourceNames=MgColNames(ncol-nSources+1:ncol);
    for i=1:nSources





        SourceNames{i}=SourceNames{i}(4:end);
    end
    SourceNames=SourceNames';



    if SPS.PowerguiInfo.DisplayEquations
        if nSources==1
            fprintf('\n1 input variable:\n')
        else
            fprintf('\n%d input variables:\n',nSources)
        end
        for i=1:nSources
            sn=['u',num2str(i),''];
            fprintf(' %-4s =  ''%s'';\n',sn,SourceNames{i})
        end
    end


    OutputNames=MgColNames(nStates+1:nStates+nOutputs);
    for i=1:nOutputs
        if strcmp(OutputNames{i}(1:3),'yv_')
            OutputNames{i}=['U',OutputNames{i}(3:end)];
        else
            OutputNames{i}=['I',OutputNames{i}(3:end)];
        end
    end
    OutputNames=OutputNames';


    if SPS.PowerguiInfo.DisplayEquations
        if nOutputs==1
            fprintf('\n1 output variable:\n')
        else
            fprintf('\n%d output variables:\n',nOutputs)
        end
        for i=1:nOutputs
            sn=['y',num2str(i),''];
            fprintf(' %-4s =  ''%s'';\n',sn,OutputNames{i})
        end
    end


    SwitchNames=MgColNames(nStates+nOutputs+1:nStates+nOutputs+2*nSwitches);
    for i=1:2*nSwitches





        SwitchNames{i}=SwitchNames{i}(10:end);
    end
    SwitchNames=SwitchNames';


    if SPS.PowerguiInfo.DisplayEquations
        if nSwitches==0
        elseif nSwitches==1
            fprintf('\n1 switch device -> 2 switch variables:\n')
        else
            fprintf('\n%d switch devices -> %d switch variables:\n',nSwitches,2*nSwitches)
        end
        k=1;
        for i=1:2:2*nSwitches
            sn=['uSW',num2str(k),''];
            fprintf(' %-4s =  ''U_%s'';\n',sn,SwitchNames{i})
            k=k+1;
        end
        k=1;
        for i=2:2:2*nSwitches
            sn=['iSW',num2str(k),''];
            fprintf(' %-4s =  ''I_%s'';\n',sn,SwitchNames{i})
            k=k+1;
        end
    end


    MgSwitch=MgRed;
    for isw=1:nb.s
        switch SPS.SwitchGateInitialValue(isw);

        case 0

            icol=nb.x+nb.y+2*isw;
            MgSwitch(:,icol)=zeros(nline,1);
        case 1

            icol=nb.x+nb.y+2*isw-1;
            MgSwitch(:,icol)=zeros(nline,1);
        end
    end










    [mrref,nrref]=size(MgSwitch);
    tol=max(mrref,nrref)*eps(class(MgSwitch))*norm(MgSwitch,'inf');


    tol=tol/200;
    MgSwitch=rref_mod(MgSwitch,tol);









    nxy=nStates+nOutputs;
    if~isdiag(MgSwitch(1:nxy,1:nxy))

    end




    n1=nStates+nOutputs+2*nSwitches;
    n2=n1+nStates+1;

    SourceTypes=char(MgColNames{n2:end});
    if nSources
        nVs=n2-1+find(SourceTypes(:,1)=='v');
    else
        nVs=[];
    end



    for i=n2:ncol
        MgColNames{i}=MgColNames{i}(4:end);
    end

    nStatesDependingOnSources=0;
    nShortedSources=0;
    str_StatesDependingOnSources=[];
    str_ShortedSources=[];

    for iline=1:nline


        if all(MgSwitch(iline,1:n1)==0)&(any(MgSwitch(iline,n1+1:n2-1)~=0)|any(abs(MgSwitch(iline,nVs))>1e-10))%#ok

            if all(MgSwitch(iline,n1+1:n2-1)==0)

                TopologyErrorType=1;
                nShortedSources=nShortedSources+1;
                if nShortedSources==1
                    str_ShortedSources=[str_ShortedSources,'\nEquations for short circuited voltage sources:\n'];%#ok

                end

            elseif any(MgSwitch(iline,n1+1:n2-1)~=0)&any(abs(MgSwitch(iline,n2:end))>1e-10)%#ok modif GS aug.3, 2007 

                TopologyErrorType=2;
                nStatesDependingOnSources=nStatesDependingOnSources+1;
                if nStatesDependingOnSources==1
                    str_StatesDependingOnSources=[str_StatesDependingOnSources,'\nEquations for state variables dependending directly on sources:\n'];%#ok
                end
            else
                TopologyErrorType=0;
            end
            for j=n1+1:ncol
                if MgSwitch(iline,j)~=0
                    coef=MgSwitch(iline,j);
                    if coef==1,
                        str1=sprintf('+%s  ',char(MgColNames{j}));
                    elseif coef==-1
                        str1=sprintf('-%s  ',char(MgColNames{j}));
                    elseif coef>0
                        str1=sprintf('+%g*%s  ',coef,char(MgColNames{j}));
                    else
                        str1=sprintf('-%g*%s  ',abs(coef),char(MgColNames{j}));
                    end
                    switch TopologyErrorType
                    case 1
                        str_ShortedSources=[str_ShortedSources,str1];%#ok
                    case 2
                        str_StatesDependingOnSources=[str_StatesDependingOnSources,str1];%#ok
                    end
                end
            end
            switch TopologyErrorType
            case 1
                str_ShortedSources=[str_ShortedSources,' = 0\n'];%#ok
            case 2
                str_StatesDependingOnSources=[str_StatesDependingOnSources,' = 0\n'];%#ok
            end
        end
    end
    nErrors=nStatesDependingOnSources+nShortedSources;
    if nErrors

        Erreur.message=sprintf(['\nInitial states of switches specified in your circuit produce %d topological error(s) at t=0\n',...
        'Check the %d circuit equations listed below:\n',...
        str_StatesDependingOnSources,str_ShortedSources],nErrors,nErrors);
        psberror(Erreur);
    end




    nDependentStates2=0;
    LineStateDep=[];
    for iline=1:nline
        if all(MgSwitch(iline,1:nStates+nOutputs+2*nSwitches)==0)&all(MgSwitch(iline,2*nStates+nOutputs+2*nSwitches+1:ncol)==0)&...
            ~all(MgSwitch(iline,nStates+nOutputs+2*nSwitches+1:2*nStates+nOutputs+2*nSwitches)==0)%#ok
            nDependentStates2=nDependentStates2+1;
            LineStateDep(nDependentStates2)=iline;%#ok
        end
    end

    if nDependentStates2>0

        idxColStates=nStates+nOutputs+2*nSwitches+1:ncol-nSources;
        idxDependentStates=zeros(1,nDependentStates2);
        MatStateDependency2=MgSwitch(LineStateDep,idxColStates);
        MatStateDependency2=rref_mod(MatStateDependency2);
        for i=1:nDependentStates2
            n=find(MatStateDependency2(i,:)~=0);
            idxDependentStates(i)=n(1);
        end

        idxIndependentStates=1:nStates;
        idxIndependentStates(idxDependentStates)=0;
        idxIndependentStates=idxIndependentStates(idxIndependentStates~=0);



        MgRed2=MgSwitch;
        ilineMatStateDependency=0;
        for i=idxDependentStates


            ilineMatStateDependency=ilineMatStateDependency+1;
            nlineDep=find(MgSwitch(:,i)~=0);
            for iline=nlineDep'
                MgRed2(iline,1:nStates)=MgRed2(iline,1:nStates)-...
                MgRed2(iline,i)*MatStateDependency2(ilineMatStateDependency,:)/MatStateDependency2(ilineMatStateDependency,i);
            end

            nlineDep=find(MgSwitch(:,i+nStates+nOutputs+2*nSwitches)~=0);
            for iline=nlineDep'
                MgRed2(iline,(1:nStates)+nStates+nOutputs+2*nSwitches)=...
                MgRed2(iline,(1:nStates)+nStates+nOutputs+2*nSwitches)-...
                MgRed2(iline,i+nStates+nOutputs+2*nSwitches)*MatStateDependency2(ilineMatStateDependency,:)/MatStateDependency2(ilineMatStateDependency,i);
            end
        end





        LineToSelect=[];
        LineToDelete=[];
        for iline=1:nline
            if~all(MgRed2(iline,:)==0)
                LineToSelect=[LineToSelect,iline];%#ok
            else
                LineToDelete=[LineToDelete,iline];%#ok
            end
        end


        ColumnToSelect=[idxIndependentStates,idxIndependentStates+nStates+nOutputs+2*nSwitches];

        ColumnToSelect=[ColumnToSelect,nStates+1:nStates+nOutputs+2*nSwitches];

        ColumnToSelect=[ColumnToSelect,ncol-nSources+1:ncol];
        ColumnToSelect=sort(ColumnToSelect);

        MgSwitch=MgRed2(LineToSelect,ColumnToSelect);
        MgSwitch=rref_mod(MgSwitch);
































        StateVarNames=StateVarNames([idxIndependentStates,idxDependentStates,nStates+1:end]);




        MatStateDependency=[MatStateDependency(:,idxIndependentStates),MatStateDependency(:,idxDependentStates),...
        MatStateDependency(:,nStates+1:end)];

        MatStateDependency=[MatStateDependency;
        [MatStateDependency2(:,idxIndependentStates),MatStateDependency2(:,idxDependentStates),...
        zeros(nDependentStates2,nDependentStates)]];
    end
    nIndependentStatesSw=nStates-nDependentStates2;
    StateVarNames=StateVarNames';




    n1=nIndependentStatesSw+nb.y+2*nb.s+1;
    n2=n1+nIndependentStatesSw-1;
    A=MgSwitch(1:nIndependentStatesSw,n1:n2);


    n1=2*nIndependentStatesSw+nb.y+2*nb.s+1;
    n2=n1+nb.u-1;
    B=MgSwitch(1:nIndependentStatesSw,n1:n2);


    n1=nIndependentStatesSw+nb.y+2*nb.s+1;
    n2=n1+nIndependentStatesSw-1;
    C=MgSwitch(nIndependentStatesSw+1:nIndependentStatesSw+nb.y,n1:n2);


    n1=2*nIndependentStatesSw+nb.y+2*nb.s+1;
    n2=n1+nb.u-1;
    D=MgSwitch(nIndependentStatesSw+1:nIndependentStatesSw+nb.y,n1:n2);

    SPS.Aswitch=A;
    SPS.Bswitch=B;
    SPS.Cswitch=C;
    SPS.Dswitch=D;

    SPS.A=A;
    SPS.B=B;
    SPS.C=C;
    SPS.D=D;


    SPS.Mg=MgRed;
    SPS.MgColNames=MgColNames;
    SPS.Mg_nb=nb;
    SPS.MatStateDependency=MatStateDependency;


    if SPS.PowerguiInfo.DisplayEquations

        if nStates+nSwitches==1
            fprintf('\nDifferential equation :\n')
        else
            if nStates==1
                PL='';
            else
                PL='s';
            end
            if nSwitches==1
                PS='';
            else
                PS='s';
            end
            fprintf('\n%d state derivative%s + %d switch device%s -> %d Differential equations:\n',nStates,PL,nSwitches,PS,nStates+nSwitches)
        end
        for i=1:nline
            str=[];
            streq=0;
            if i==nStates+nSwitches+1;
                if nOutputs==1
                    fprintf('\n1 output equation:\n');
                else
                    fprintf('\n%d output equations:\n',nOutputs);
                end
            end
            for j=1:ncol
                if j==(nStates+2*nSwitches+nOutputs+1)&~isempty(str)%#ok
                    str=[str,'= '];%#ok
                    streq=1;
                end
                if MgRed(i,j)~=0
                    coef=MgRed(i,j);

                    if j>0&&j<=nStates
                        offset=0;
                        if coef==1,
                            str1=sprintf('+ dx%d/dt ',j-offset);
                        elseif coef==-1
                            str1=sprintf('- dx%d/dt ',j-offset);
                        elseif coef>0
                            str1=sprintf('+ %g*dx%d/dt ',coef,j-offset);
                        else
                            str1=sprintf('- %g*dx%d/dt ',abs(coef),j-offset);
                        end

                    elseif j>nStates&&j<=nStates+nOutputs
                        offset=nStates;
                        if coef==1,
                            str1=sprintf('+ y%d ',j-offset);
                        elseif coef==-1
                            str1=sprintf('- y%d ',j-offset);
                        elseif coef>0
                            str1=sprintf('+ %g*y%d ',coef,j-offset);
                        else
                            str1=sprintf('- %g*y%d ',abs(coef),j-offset);
                        end

                    elseif j>nStates+nOutputs&&j<=nStates+nOutputs+2*nSwitches
                        FirstSwitch=nStates+nOutputs+1;
                        SW=MgColNames(j);
                        if SW{1}(1)=='v'
                            TP='u';
                            Swnb=((j-FirstSwitch)/2)+1;
                        else
                            TP='i';
                            Swnb=((j-FirstSwitch)/2)+0.5;





                        end
                        if coef==1,
                            str1=sprintf('+ %sSW%d ',TP,Swnb);
                        elseif coef==-1
                            str1=sprintf('- %sSW%d ',TP,Swnb);
                        elseif coef>0
                            str1=sprintf('+ %g*%sSW%d ',coef,TP,Swnb);
                        else
                            str1=sprintf('- %g*%sSW%d ',abs(coef),TP,Swnb);
                        end

                    elseif j>nStates+nOutputs+2*nSwitches&&j<=nStates+nOutputs+2*nSwitches+nStates
                        offset=nStates+nOutputs+2*nSwitches;
                        if coef==1,
                            str1=sprintf('+ x%d ',j-offset);
                        elseif coef==-1
                            str1=sprintf('- x%d ',j-offset);
                        elseif coef>0
                            str1=sprintf('+ %g*x%d ',coef,j-offset);
                        else
                            str1=sprintf('- %g*x%d ',abs(coef),j-offset);
                        end

                    elseif j>nStates+nOutputs+2*nSwitches+nStates
                        offset=nStates+nOutputs+2*nSwitches+nStates;
                        if coef==1,
                            str1=sprintf('+ u%d ',j-offset);
                        elseif coef==-1
                            str1=sprintf('- u%d ',j-offset);
                        elseif coef>0
                            str1=sprintf('+ %g*u%d ',coef,j-offset);
                        else
                            str1=sprintf('- %g*u%d ',abs(coef),j-offset);
                        end
                    end
                    if abs(coef)>TrimNoiseValue
                        str=[str,str1];%#ok
                    end
                end
            end
            if~streq
                str=[str,'= 0'];%#ok
            end
            if strcmp(str(end-1:end),'= ')
                str=[str,' 0'];%#ok
            end

            fprintf(' %s\n',str)
        end
        fprintf('\n')
    end