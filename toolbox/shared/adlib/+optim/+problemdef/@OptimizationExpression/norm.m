function eout=norm(obj,normType)












    isvec=isvector(obj);


    if nargin>1

        if~strcmp(normType,'fro')

            if~(isnumeric(normType)&&isscalar(normType)&&isreal(normType))
                error(message('shared_adlib:operators:NonsenseNormType'));
            end

            if~isvec&&~(isequal(normType,1)||isequal(normType,2)||isequal(normType,Inf))
                error(message('shared_adlib:operators:InvalidMatrixNormType'));
            end

            if~ismatrix(obj)
                throw(MException('shared_adlib:operators:InvalidNDNormType',...
                getString(message('MATLAB:norm:inputMustBe2D'))));
            end
        end
    else

        if~ismatrix(obj)
            throw(MException('shared_adlib:operators:InvalidNDNormType',...
            getString(message('MATLAB:norm:inputMustBe2D'))));
        end

        normType=2;
    end

    if isequal(normType,2)&&isvec

        eout=sqrt(sum(obj.^2,'all'));
    else

        eout=optim.problemdef.fcn2optimexpr(@norm,obj,normType,'Analysis','off','OutputSize',[1,1],...
        'Display','off');
    end
