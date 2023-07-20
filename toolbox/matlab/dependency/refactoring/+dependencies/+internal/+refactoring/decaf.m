function oldValue=decaf(newValue)





%#ok<*JAPIMATHWORKS>
    if nargin>0
        oldValue=com.mathworks.toolbox.slproject.extensions.dependency.refactoring.RefactoringBuilder.setDecaf(newValue);
    else
        oldValue=com.mathworks.toolbox.slproject.extensions.dependency.refactoring.RefactoringBuilder.isDecaf();
    end

end
