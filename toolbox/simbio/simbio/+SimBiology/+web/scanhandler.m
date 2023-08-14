function out=scanhandler(action,varargin)











    switch(action)
    case 'verifyScanValues'
        out=verifyScanValues(action,varargin);
    case 'verifyMatrix'
        out=verifyMatrix(action,varargin{:});
    end

end

function out=verifyScanValues(action,inputs)

    inputs=[inputs{:}];
    for i=1:numel(inputs)
        code=inputs(i).code;
        property=inputs(i).property;
        msg='';
        numIterations=0;

        try


            temp=eval(code);
            numIterations=length(temp);
            if(numIterations~=numel(temp))||numIterations==0||~isnumeric(temp)
                msg='The expression must evaluate to a non-empty vector of doubles';
            end


            switch(property)
            case{'Amount','StartTime','Interval','Rate'}
                if any(temp<0)||any(isnan(temp))||any(isinf(temp))
                    msg=sprintf('The dose property, ''%s'' cannot be negative, inf or NaN',property);
                end

            case 'RepeatCount'
                if any(temp<0)||any(isnan(temp))||any(isinf(temp))||~all(temp==floor(temp))
                    msg=sprintf('The dose property, ''%s'' must be a positive scalar and cannot be inf or NaN',property);
                end

            case 'compartment'
                if any(temp<0)||any(isnan(temp))||any(isinf(temp))||any(temp==0)
                    msg='Capacity for a compartment must be a positive scalar and cannot be inf or NaN';
                end

            case 'species'
                if any(temp<0)||any(isnan(temp))||any(isinf(temp))
                    msg='The IntialAmount for a species cannot be negative, inf or NaN';
                end
            end
        catch ex
            msg=SimBiology.web.internal.errortranslator(ex);
        end

        inputs(i).message=msg;
        inputs(i).numIterations=numIterations;
    end

    out={action,inputs};

end

function out=verifyMatrix(action,input)

    names={input.data.name};
    covInfo=input.data;
    matrix=generateCovarianceMatrix(names,covInfo);


    results.valid=true;

    switch input.type
    case 'covariance'
        if~issymmetric(matrix)||eigs(matrix,1,'smallestreal')<0
            results.valid=false;
        end

    case 'correlation'

        [~,p]=chol(matrix);

        if any(diag(matrix)~=1)||~issymmetric(matrix)||p>0
            results.valid=false;
        end
    end

    out={action,results};

end

function covMatrix=generateCovarianceMatrix(names,covInfo)

    covMatrix=SimBiology.web.codegenerationutil('generateCovarianceMatrix',names,covInfo);

end
