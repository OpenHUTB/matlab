classdef jc_0803<slcheck.subcheck




    properties(Access=private)
Mode
Algorithm
algoName
    end

    methods
        function obj=jc_0803(InitParams)
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID=InitParams.Name;


            [obj.Algorithm,obj.Mode,obj.algoName]=setFunction(InitParams.Mode);
        end


        function result=run(this)
            result=false;


            obj=this.getEntity();

            if isempty(obj.LabelString)
                return;
            end

            label=obj.LabelString;


            label=regexprep([label,newline],'((//|%).*?\n)',' ');
            label=regexprep(label,'(/\*.*?\*/)',' ');


            if this.Mode&&hasFunctionOnce(label,this.algoName)
                result=true;
            end


            if~this.Mode&&this.Algorithm(label)
                result=true;
            end

            if result
                result=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(result,'SID',obj);
                this.setResult(result);
            end
        end
    end
end


function res=jc_0803_abs(label)
    matches=getMatches(label,'abs');

    res=any(cellfun(@(x)(str2double(x{1})<-127),matches));
end


function res=jc_0803_sqrt(label)
    matches=getMatches(label,'sqrt');
    res=any(cellfun(@(x)str2double(x{1})<0,matches));
end


function res=jc_0803_log(label)
    matches=getMatches(label,'log');
    res=any(cellfun(@(x)str2double(x{1})<0,matches));
end


function res=jc_0803_fmod(label)
    res=false;
    matches=getMatches(label,'fmod');
    for i=1:length(matches)
        val=matches{i};
        arg=strsplit(val{1},',');
        arg=arg{end};
        if~str2double(arg)
            res=true;
            return;
        end
    end
end


function res=getMatches(str,pattern)
    res=regexp(str,['(?<!\w)',pattern,'\((.*?)\)'],'match');
    if~isempty(res)
        res=regexp(res,'(?<=\().*(?=\))','match');
    end
end


function res=hasFunctionOnce(str,pattern)
    res=~isempty(regexp(str,['(?<!\w)',pattern,'\((.*?)\)'],'once'));
end


function[res,mode,algoName]=setFunction(mode)

    switch floor(mode/10)
    case 1
        res=@jc_0803_abs;
        algoName='abs';
    case 2
        res=@jc_0803_sqrt;
        algoName='sqrt';
    case 3
        res=@jc_0803_log;
        algoName='log';
    case 4
        res=@jc_0803_fmod;
        algoName='fmod';
    otherwise


        ME=MException('slcheck:FailedRegistraion',...
        'JC_0803 : Invalid subcheck mode');
        throw(ME);
    end




    if rem(mode,10)==2
        mode=true;
    else
        mode=false;
    end
end

