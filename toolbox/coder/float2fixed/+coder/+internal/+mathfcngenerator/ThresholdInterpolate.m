








classdef ThresholdInterpolate<handle


    properties
ErrorMetric
ErrorThreshold
CandidateFunction
InputExtents
InterpolationDegree
        MaxTries=25;
    end


    properties(SetAccess=private,GetAccess=public)
LUT
InputDomain
N
    end

    properties(Access=private,Constant)
        Failed=false;
        Succeeded=true;
        Strategy='BinarySearch';
    end

    methods(Access=private)
        function flag=sanityCheck(this)


            flag=(this.MaxTries>0)&&any(this.ErrorThreshold);
        end


        function estError=FinalErrorEstimate(this)
            estError=this.ErrorEstimate(this.InputDomain,this.InputExtents);
        end

        function estError=ErrorEstimate(this,currXtents,domain)
            L=numel(currXtents);
            M=L*5;
            xpts=linspace(domain(1),domain(2),M);
            estLUT=arrayfun(this.CandidateFunction,xpts);
            ypts=arrayfun(this.CandidateFunction,currXtents);
            interLUT=this.Interpolate(currXtents,ypts,xpts);





            AE=abs(estLUT-interLUT);

            switch(this.ErrorMetric)
            case 'Absolute'
                estError=max(AE);
            case 'Relative'
                estError=sum(abs(AE./estLUT));
            case 'Relative-Mean-Squared'
                estError=sum((AE).^2)./sum(estLUT.^2);
            case 'Mean-Squared'
                estError=sqrt(sum((AE).^2));
            otherwise
                error('MATLAB Object reached an inconsistent state')
            end

        end
        function y=Interpolate(this,X,Y,Xint)
            switch(this.InterpolationDegree)
            case 0
                y=interp1(X,Y,Xint,'nearest');
            case 1
                y=interp1(X,Y,Xint,'linear');
            case 3
                y=interp1(X,Y,Xint,'cubic');
            end
        end



        function[currExt,nextFirst]=SectionalOptimize(this,first,last)
            nextFirst=[];
            attempts=1;
            prevLast=last;
            while(attempts<=this.MaxTries)
                mid=(first+last)/2;
                currExt=[first,mid,last].';
                if(this.ErrorEstimate(currExt,[first,last])<=this.ErrorThreshold)


                    newLast=last;
                    count_x=0;
                    while(newLast<prevLast)
                        count_x=count_x+1;

                        newLast=(last+prevLast)/2;
                        midLast=(newLast+prevLast)/2;

                        mid=(first+newLast)/2;
                        currExt=[first,mid,newLast].';

                        if(this.ErrorEstimate(currExt,[first,newLast])<=this.ErrorThreshold)
                            last=newLast;
                            newLast=(midLast+prevLast)/2;
                        else
                            prevLast=midLast;
                        end

                        if(count_x>10)
                            break;
                        end
                    end

                    nextFirst=last;
                    return;
                else
                    prevLast=last;
                    last=mid;
                    attempts=attempts+1;
                end

            end

            if(attempts>this.MaxTries)
                error(message('float2fixed:MFG:ThresholdOptimNonConvergent'))
            end

        end
    end

    methods

        function this=set.InterpolationDegree(this,val)
            if(val~=1&&val~=0&&val~=3)
                error(message('float2fixed:MFG:ThresholdInterpolationUnimplemented'))
            end
            this.InterpolationDegree=val;
        end

        function this=set.ErrorMetric(this,val)
            flag=any(strcmpi({'Relative','Mean-Squared','Relative-Mean-Squared','Absolute'},val));
            assert(flag)
            this.ErrorMetric=val;
        end

        function this=ThresholdInterpolate(varargs)
            this.ErrorMetric='Absolute';
            this.ErrorThreshold=1e-3;
            for itr=1:2:nargin
                this.(varargs{itr})=varargs{itr+1};
            end
            this.InterpolationDegree=1;
            this.InputDomain=[];
            this.N=[];
            this.LUT=[];
        end

        function outcome=optimize(this)

            assert(this.sanityCheck());
            outcome=this.Failed;

            first=this.InputExtents(1);
            last=this.InputExtents(2);
            nextFirst=first;
            try
                this.InputDomain=[first];


                while(nextFirst<last)
                    [currExt,nextFirst]=this.SectionalOptimize(first,last);

                    first=nextFirst;
                    this.InputDomain=[this.InputDomain;currExt(2:end)];
                end

            catch Ex
Ex
                rethrow(Ex)
            end


            this.LUT=arrayfun(this.CandidateFunction,this.InputDomain);
            outcome=this.Succeeded;
            this.N=numel(this.LUT);
        end

        function h=plot_interp(this)
            figure;
            plot(this.InputDomain,this.LUT,'-or');
            title(['Plot LUT for ',func2str(this.CandidateFunction),' of object ',class(this)])
            xlabel('Input domain (x)')
            ylabel(' y = f(x)')
            legend({'Lookup table points'})
            h=gcf();
        end

        function disp(this)
            if(isempty(this.N)||isempty(this.InputDomain))
                disp(['Optimization not run for function ',func2str(this.CandidateFunction)])
                return;
            end

            disp(['Optimization successfully run for function ',func2str(this.CandidateFunction)])
            disp(['Under the error-metric ',this.ErrorMetric,' we acheived the ',num2str(this.N),' interpolation points.'])
            disp(['Following is a list of input points: ']);
            disp([[1:this.N]',this.InputDomain,this.LUT]);
            disp(['With an error estimate of ',num2str(this.FinalErrorEstimate())]);
            disp(['Size of LUT : ',num2str(numel(this.LUT))])
            this.plot_interp();
        end
    end
end
