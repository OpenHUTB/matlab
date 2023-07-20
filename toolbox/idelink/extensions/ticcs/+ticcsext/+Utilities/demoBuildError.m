function errmsg=demoBuildError(cc,errmsg,demopjt)




    if nargin<=2||(nargin>2&&isempty(demopjt))
        pjtInfo='the project';
    else
        pjtInfo=sprintf('project:\n\t%s',demopjt.ProjectFile);
    end


    cc.visible(1);


    errmsg=sprintf(['\n%s\n\n',...
    'A problem occurred while building the CCS project for this demo.\n',...
    'Go to CCS, fix the problem in %s. \n',...
    'Build and save the project, then rerun the demo.'],...
    errmsg,pjtInfo);

