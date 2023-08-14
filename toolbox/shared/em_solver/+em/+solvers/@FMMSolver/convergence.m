function varargout=convergence(obj)


















    narginchk(1,1);
    nargoutchk(0,1);
    if nargout==0
        hfig=gcf;
        titlestr=sprintf('Convergence');
        if~isempty(get(groot,'CurrentFigure'))
            clf(hfig);
        end
        semilogy(obj.ResidualVector,'-o');
        grid on;
        xlabel('Iterations')
        ylabel('Relative residual')
        title(titlestr)
shg
    elseif nargout==1
        varargout{1}=obj.ResidualVector;
    end

end