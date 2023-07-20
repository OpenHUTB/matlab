


































function[xint,fint,exitflag]=intervalSearch(fcn,x0,Dxa,Dxb,nDx,dx,...
    b0_in,xl_in,xu_in,tolf_in,maxeval_in,printtype_in)

%#codegen
    coder.allowpcode('plain')


    if nargin<7||isempty(b0_in)
        b0=x0+Dxb;
    else
        b0=b0_in;
    end
    if nargin<8||isempty(xl_in)
        xl=-inf;
    else
        xl=xl_in;
    end
    if nargin<9||isempty(xu_in)
        xu=inf;
    else
        xu=xu_in;
    end
    if nargin<10||isempty(tolf_in)
        tolf=eps;
    else
        tolf=tolf_in;
    end
    if nargin<11||isempty(maxeval_in)
        maxeval=1000;
    else
        maxeval=maxeval_in;
    end
    if nargin<12||isempty(printtype_in)
        printtype='off';
    else
        printtype=printtype_in;
    end


    dispi=false;
    dispf=false;
    if strcmpi(printtype,'iter')
        dispi=true;
        dispf=true;
    end
    if strcmp(printtype,'final')
        dispf=true;
    end


    count=0;


    xint=[NaN,NaN];
    fint=[NaN,NaN];


    xb1=x0;
    [fb1,xint,fint,count,exitflag]=evalFcn(fcn,xb1,...
    xint,fint,count,tolf,maxeval,false,dispf);
    if exitflag~=0
        return
    end
    xb2=xb1;
    fb2=fb1;
    xa1=xb1;
    fa1=fb1;
    xa2=xb1;
    fa2=fb1;



    dir=-sign(fb1);

    if dispi
        fprintf('\n Func-count    a          f(a)             b          f(b)        Procedure\n')
    end


    Dxalim=nDx*Dxa;
    Dxblim=nDx*Dxb;


    posdir=true;
    negdir=true;
    while posdir||negdir

        if posdir
            xb2=xb1+Dxb;
            if xb2>=xu
                xb2=xu;
                posdir=false;
            end
            [fb2,xint,fint,count,exitflag]=evalFcn(fcn,xb2,...
            xint,fint,count,tolf,maxeval,dispi,dispf,'pos dir step');
            if exitflag~=0
                return
            end
        end


        while posdir&&(sign(fb2-fb1)==dir)

            xb3=(xb1*fb2-xb2*fb1)/(fb2-fb1)+dx;
            if xb3>xb2+Dxblim
                xb3=xb2+Dxblim;
            end
            if xb3>=xu
                xb3=xu;
                posdir=false;
            end
            [fb3,xint,fint,count,exitflag]=evalFcn(fcn,xb3,...
            xint,fint,count,tolf,maxeval,dispi,dispf,'pos dir interp');
            if exitflag~=0
                return
            end

            xb1=xb2;
            fb1=fb2;
            xb2=xb3;
            fb2=fb3;
        end

        xb1=xb2;
        fb1=fb2;


        if xb1<b0
            continue
        end


        if negdir
            xa2=xa1-Dxa;
            if xa2<=xl
                xa2=xl;
                negdir=false;
            end
            [fa2,xint,fint,count,exitflag]=evalFcn(fcn,xa2,...
            xint,fint,count,tolf,maxeval,dispi,dispf,'neg dir step');
            if exitflag~=0
                return
            end
        end


        while negdir&&(sign(fa2-fa1)==dir)

            xa3=(xa1*fa2-xa2*fa1)/(fa2-fa1)-dx;
            if xa3<xa2-Dxalim
                xa3=xa2-Dxalim;
            end
            if xa3<=xl
                xa3=xl;
                negdir=false;
            end
            [fa3,xint,fint,count,exitflag]=evalFcn(fcn,xa3,...
            xint,fint,count,tolf,maxeval,dispi,dispf,'neg dir interp');
            if exitflag~=0
                return
            end

            xa1=xa2;
            fa1=fa2;
            xa2=xa3;
            fa2=fa3;
        end

        xa1=xa2;
        fa1=fa2;
    end

    exitflag=-3;
    if dispf
        fprintf('\n Search has reached both upper and lower limits after %d function evaluations\n',...
        count)
    end

end




function[f,xint,fint,count,exitflag]=evalFcn(fcn,x,...
    xint,fint,count,tolf,maxeval,dispi,dispf,proc)


    f=fcn(x);
    count=count+1;


    xint(2)=xint(1);
    fint(2)=fint(1);
    xint(1)=x;
    fint(1)=f;

    if dispi&&all(isfinite(xint))
        if xint(1)<xint(2)
            xmin=xint(1);
            fmin=fint(1);
            xmax=xint(2);
            fmax=fint(2);
        else
            xmin=xint(2);
            fmin=fint(2);
            xmax=xint(1);
            fmax=fint(1);
        end
        fprintf('%5.0f   %13.6g %13.6g %13.6g %13.6g   %s\n',count,xmin,fmin,xmax,fmax,proc);
    end


    if~isfinite(f)
        exitflag=-1;
        if dispf
            fprintf('\n Nonfinite function evaluation detected at x = %g\n',x)
        end
    elseif abs(f)<=tolf
        exitflag=2;
        if dispf
            fprintf('\n Function value within tolerance of zero at x = %g\n',x)
        end
    elseif isfinite(fint(2))&&(sign(fint(1))~=sign(fint(2)))
        exitflag=1;
        if dispf
            fprintf('\n Interval found x = [%g, %g] with f = [%g, %g] after %d function evaluations\n',...
            xint(1),xint(2),fint(1),fint(2),count)
        end
    elseif count>=maxeval
        exitflag=-2;
        if dispf
            fprintf('\n Max function evaluations reached\n')
        end
    else
        exitflag=0;
    end

end