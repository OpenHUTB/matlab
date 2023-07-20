function[A,B,C,D]=dlinmodv5(model,varargin)




















































    if~is_simulink_loaded
        load_simulink;
    end

    fUDBusVal=sl('busUtils','handleunitdelaybus',0);
    fUDBusValCleanup=onCleanup(...
    @()sl('busUtils','handleunitdelaybus',fUDBusVal));


    supportMsg=linmodsupported(model);
    if~isempty(supportMsg)
        error(supportMsg);
    end


    [normalblks,normalrefs]=getLinNormalModeBlocks(model);
    models=[model;normalrefs];


    want=struct('SimulationMode','normal','RTWInlineParameters','on','InitInArrayFormatMsg','None');
    [have,preloaded]=local_push_context(models,want);


    if~checkSingleTaskingSolver(models)
        DAStudio.error('Simulink:tools:dlinmodMultiTaskingSolver');
    end


    feval(model,[],[],[],'lincompile');


    errmsg=[];
    try
        [A,B,C,D]=dlinmod_alg(model,varargin{:});
    catch e
        errmsg=e;
    end


    feval(model,[],[],[],'term');
    local_pop_context(models,have,preloaded);


    if~isempty(errmsg)
        rethrow(errmsg);
    end





    function[A,B,C,D]=dlinmod_alg(model,st,x,u,para,xpert,upert)


        [sizes,x0,x_str,ts,tsx]=feval(model,[],[],[],'sizes');
        sizes=[sizes(:);zeros(6-length(sizes),1)];
        nu=sizes(4);

        if nargin<2,st=[];end
        if nargin<3,x=[];end
        if nargin<4,u=[];end
        if nargin<5,para=[];end
        if nargin<6,xpert=[];end
        if nargin<7,upert=[];end


        if isempty(u),u=zeros(nu,1);end




        mdlrefflag=~isempty(find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','ModelReference'));


        if isempty(x)
            if mdlrefflag
                x=sl('getInitialState',model);
            else
                x=x0;
            end
        else
            if mdlrefflag&&~isstruct(x)
                DAStudio.error('Simulink:tools:dlinmodv5RequireStateStruct')
            end
        end



        if isstruct(x)
            tsx=struct2vect(x,'sampleTime');
        else
            if~isempty(tsx),tsx=tsx(:,1);end
        end


        nxz=length(tsx);

        if isempty(para),para=[0;0;0];end
        if para(1)==0,para(1)=1e-5;end
        if isempty(upert),upert=para(1)+1e-3*para(1)*abs(u);end
        if isempty(xpert)
            if isstruct(x)

                xpert=x;

                for ct=1:length(x.signals)
                    xval=x.signals(ct).values;
                    xpert.signals(ct).values=para(1)+1e-3*para(1)*abs(xval);
                end
            else
                xpert=para(1)+1e-3*para(1)*abs(x);
            end
        end
        if~mdlrefflag&&~isstruct(x)&&length(x)<nxz
            MSLDiagnostic('Simulink:tools:dlinmodExtraStatesZero').reportAsWarning
            x=[x(:);zeros(nxz-length(x),1)];
        end
        if length(para)>1,t=para(2);else t=0;end
        if length(para)<3,para(3)=0;end

        ts=[0,0;ts];


        tsnew=unique(ts(:,1));
        [nts]=length(tsnew);

        if isempty(st)
            st=local_vlcm(tsnew(tsnew>0));
            if isempty(st)
                MSLDiagnostic('Simulink:tools:dlinmodNoSampleTimeFound').reportAsWarning;
                st=1;
            end
        end


        if isstruct(x)


            model_struct=sl('getInitialState',model);
            nsignals=numel(model_struct.signals);
            blocknames={model_struct.signals.blockName};
            indsort=zeros(nsignals,1);
            for ct=1:nsignals
                indsort(strcmp(x.signals(ct).blockName,blocknames))=ct;
            end
            x.signals=x.signals(indsort);


            if~isstruct(xpert)
                DAStudio.error('Simulink:tools:dlinmodv5StateStructXPert')
            end



            indsort=zeros(nsignals,1);
            for ct=1:nsignals
                indsort(strcmp(xpert.signals(ct).blockName,blocknames))=ct;
            end
            xpert.signals=xpert.signals(indsort);


            for ct=length(x.signals):-1:1
                if~strcmp(class(x.signals(ct).values),'double')
                    x.signals(ct)=[];
                    xpert.signals(ct)=[];
                end
            end
        end




        oldx=x;oldu=u;

        feval(model,[],[],[],'all');
        y=struct2vect(feval(model,t,x,u,'outputs'),'values');
        dall=compdxds(model,t,x,u);
        oldy=y;olddall=dall;


        A=zeros(nxz,nxz);B=zeros(nxz,nu);Acd=A;Bcd=B;
        Aeye=eye(nxz,nxz);


        ny=numel(y);
        C=zeros(ny,nxz);D=zeros(ny,nu);





        for m=1:nts

            if length(tsnew)>1
                stnext=min(st,tsnew(2));
            else
                stnext=st;
            end
            storig=tsnew(1);
            index=find(tsx==storig);
            nindex=find(tsx~=storig);
            oldA=Acd;
            oldB=Bcd;











            feval(model,storig,[],[],'all');
            Acd=zeros(nxz,nxz);Bcd=zeros(nxz,nu);






            feval(model,t,x,u,'outputs');
            compdxds(model,t,x,u);
            for ct=1:nu
                u(ct)=u(ct)+upert(ct);
                y=struct2vect(feval(model,t,x,u,'outputs'),'values');
                if ny>0
                    D(:,ct)=(y-oldy)./upert(ct);
                end
                u=oldu;
            end

            if isstruct(x)

                ctr=1;
                for ct1=1:length(x.signals);
                    for ct2=1:length(x.signals(ct1).values)
                        xpertval=xpert.signals(ct1).values(ct2);
                        xval=x.signals(ct1).values(ct2);
                        x.signals(ct1).values(ct2)=xval+xpertval;

                        y=struct2vect(feval(model,t,x,u,'outputs'),'values');
                        dall=compdxds(model,t,x,u);
                        Acd(:,ctr)=(dall-olddall)./xpertval;
                        if ny>0
                            C(:,ctr)=(y-oldy)./xpertval;
                        end
                        x=oldx;
                        ctr=ctr+1;
                    end
                end
            else



                oldx=x;oldu=u;
                y=struct2vect(feval(model,t,x,u,'outputs'),'values');
                dall=compdxds(model,t,x,u);
                oldy=y;olddall=dall;

                for ct=1:nxz;
                    x(ct)=x(ct)+xpert(ct);
                    y=struct2vect(feval(model,t,x,u,'outputs'),'values');
                    dall=compdxds(model,t,x,u);
                    Acd(:,ct)=(dall-olddall)./xpert(ct);
                    if ny>0
                        C(:,ct)=(y-oldy)./xpert(ct);
                    end
                    x=oldx;
                end
            end


            for ct=1:nu
                u(ct)=u(ct)+upert(ct);
                feval(model,t,x,u,'outputs');
                dall=compdxds(model,t,x,u);
                if~isempty(Bcd)
                    Bcd(:,ct)=(dall-olddall)./upert(ct);
                end
                u=oldu;
            end







            A=A+Aeye*(Acd-oldA);
            B=B+Aeye*(Bcd-oldB);
            n=length(index);





            if n&&storig~=stnext
                if storig~=0
                    if stnext~=0
                        [ad2,bd2]=linmod_d2d(A(index,index),eye(n,n),storig,stnext);
                    else
                        [ad2,bd2]=d2ci(A(index,index),eye(n,n),storig);
                    end
                else
                    [ad2,bd2]=linmod_c2d(A(index,index),eye(n,n),stnext);
                end
                A(index,index)=ad2;

                if~isempty(nindex)
                    A(index,nindex)=bd2*A(index,nindex);
                end
                if nu
                    B(index,:)=bd2*B(index,:);
                end


                Aeye(index,index)=bd2*Aeye(index,index);
                tsx(index)=stnext(ones(length(index),1));
            end


            tsnew(1)=[];
        end

        if norm(imag(A),'inf')<sqrt(eps),A=real(A);end
        if norm(imag(B),'inf')<sqrt(eps),B=real(B);end




        if para(3)==1
            [A,B,C,~]=minlin(A,B,C);
        end


        if nargout==2

            [A,B]=feval('ss2tf',A,B,C,D,1);
        end




        function dall=compdxds(model,t,x,u)


            dx=feval(model,t,x,u,'derivs');
            ds=feval(model,t,x,u,'update');

            if isstruct(x)


                if~isempty(dx)
                    for ct=1:length(dx.signals)
                        ind=strcmp(dx.signals(ct).blockName,{ds.signals.blockName});
                        ds.signals(ind).values=dx.signals(ct).values;
                    end
                end
                dall=struct2vect(ds,'values');
            else
                dall=[dx;ds];
            end





            function x=struct2vect(xstr,field)

                if isstruct(xstr)

                    for ct=length(xstr.signals):-1:1
                        if~strcmp(class(xstr.signals(ct).values),'double')
                            xstr.signals(ct)=[];
                        end
                    end


                    nels=sum([xstr.signals.dimensions]);


                    x=zeros(nels,1);


                    ind=1;


                    for ct=1:length(xstr.signals)
                        if strcmp(field,'values')
                            x(ind:ind+prod(xstr.signals(ct).dimensions)-1)=xstr.signals(ct).(field);
                        else
                            tsx=xstr.signals(ct).(field);
                            x(ind:ind+prod(xstr.signals(ct).dimensions)-1)=tsx(1:end,1);
                        end
                        ind=ind+prod(xstr.signals(ct).dimensions);
                    end
                else
                    x=xstr;
                end


                function M=local_vlcm(x)



                    x(~x)=[];
                    x(isinf(x))=[];
                    if isempty(x),M=[];return;end;

                    [a,b]=rat(x);
                    v=b(1);
                    for k=2:length(b),v=lcm(v,b(k));end
                    d=v;

                    y=round(d*x);
                    v=y(1);
                    for k=2:length(y),v=lcm(v,y(k));end
                    M=v/d;


                    function[old_values,preloaded]=local_push_context(models,new)


                        preloaded=false(numel(models),1);

                        for ct=numel(models):-1:1

                            if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',models{ct}))
                                load_system(models{ct});
                            else
                                preloaded(ct)=true;
                            end


                            old=struct('Dirty',get_param(models{ct},'Dirty'));

                            f=fieldnames(new);
                            for k=1:length(f)
                                prop=f{k};
                                have_val=get_param(models{ct},prop);
                                want_val=new.(prop);
                                set_param(models{ct},prop,want_val);
                                old.(prop)=have_val;
                            end
                            old_values(ct)=old;
                        end


                        function local_pop_context(models,old,preloaded)


                            for ct=numel(models):-1:1
                                f=fieldnames(old);
                                for k=1:length(f)
                                    prop=f{k};
                                    if~isequal(prop,'Dirty')
                                        set_param(models{ct},prop,old(ct).(prop));
                                    end
                                end

                                set_param(models{ct},'Dirty',old(ct).Dirty);

                            end

