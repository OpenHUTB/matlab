function tuvar=create_sl_input_variable(XData,YData,signalCnt)





    xVars=cell(1,signalCnt);
    yVars=cell(1,signalCnt);

    for i=1:signalCnt
        [xVars{i},yVars{i}]=remove_duplicate_points(XData{i},YData{i});





        [xVars{i},yVars{i}]=insert_zc_points(xVars{i},yVars{i});
    end

    [T,U]=generate_TU_pair(xVars{:},yVars{:});
    tuvar=[T,U];
end



function[Tnew,Unew]=generate_TU_pair(varargin)






    if mod(nargin,2)~=0
        error(message('sigbldr_blk:generate_TU_pair:needMatchedTYInputs'));
    end

    nVars=nargin/2;
    indVar=cell(1,nVars);

    [T,indVar{:}]=common_time_vect(varargin{1:(nVars)});



    T=T(:);
    U=[];
    dup=cell(1,nVars);
    Irepeat=cell(1,nVars);
    dupValues=[];

    for i=1:nVars
        I=indVar{i};


        irep=find(diff(I)==0);
        dup{i}=I(irep);
        Irepeat{i}=sort([irep,irep+1]);
        dupValues=[dupValues,dup{i}];

        t_in=varargin{i};
        y_in=varargin{i+nVars};

        Y(I)=y_in;

        int_lft=find(diff(I)>1);
        if~isempty(int_lft)

            Idx_in=repmat([0,1],length(int_lft),1)+repmat(int_lft',1,2);
            Idx_out=I(Idx_in);
            slope=diff(y_in(Idx_in),1,2)./diff(t_in(Idx_in),1,2);
            term1=y_in(int_lft)-t_in(int_lft).*slope';
            for k=1:length(slope)
                Idx_interp=(Idx_out(k,1)+1):(Idx_out(k,2)-1);
                Y(Idx_interp)=term1(k)+T(Idx_interp)*slope(k);
            end
        end

        U=[U,Y'];
    end


    dupValues=sort(dupValues);
    dupValues(diff(dupValues)==0)=[];


    reMap=1:length(T);
    reMap=sort([reMap,dupValues]);


    Tnew=T(reMap);
    Unew=U(reMap,:);

    for i=1:nVars
        y_in=varargin{i+nVars};
        Irep=Irepeat{i};
        dupInIdx=dup{i};
        Iout=ismember(reMap,dupInIdx);
        Unew(Iout,i)=y_in(Irep)';
        Unew(Iout,i)=y_in(Irep)';
    end
end

function varargout=common_time_vect(varargin)






    if nargout==0||(nargout>1&&nargout~=(nargin+1))
        error(message('sigbldr_blk:common_time_vect:inconsistentArguments'));
    end


    allTimes=[];
    for i=1:nargin
        allTimes=[allTimes,varargin{i}(:)'];
    end

    T=sort(allTimes);
    T(diff(T)==0)=[];

    varargout{1}=T;

    if nargout>1,
        for i=1:nargin
            Tin=varargin{i}(:)';
            rawInd=find(diff(sort([T,Tin]))==0);
            varargout{i+1}=rawInd-(1:length(rawInd))+1;
        end
    end
end

function[x,y]=insert_zc_points(x,y)















    n=length(x);
    dx=diff(x);
    dy=diff(y);
    duplicateX=dx==0;



    slope=zeros(size(dy));
    slope(~duplicateX)=dy(~duplicateX)./dx(~duplicateX);
    slope(duplicateX)=inf;




    inflection=[false,diff(slope)~=0];




    zc=[inflection&~duplicateX&[false,~duplicateX(1:end-1)],false];











    idx=1:(n+sum(zc));
    zlocs=find(zc==true);
    zci=zeros(1,n+sum(zc));
    intindx=1:length(zlocs);
    zci(zlocs+intindx)=1;
    czc=cumsum(zci);
    idx=idx-czc;


    x=x(idx);
    y=y(idx);
end

function[x,y]=remove_duplicate_points(x,y)

    isDuplicate=(x(1:(end-1))==x(2:end)&y(1:(end-1))==y(2:end));
    x(isDuplicate)=[];
    y(isDuplicate)=[];
end

