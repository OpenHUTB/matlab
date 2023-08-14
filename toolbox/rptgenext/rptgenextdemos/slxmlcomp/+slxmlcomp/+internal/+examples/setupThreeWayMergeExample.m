


function projectRoot=setupThreeWayMergeExample()

    sldemo_slproject_airframe;
    proj=matlab.project.currentProject();
    projectRoot=proj.RootFolder;

    mineProjectEditFcn='slxmlcomp.internal.examples.ThreeWayMerge.doMineProjectEdit';
    theirsProjectEditFcn='slxmlcomp.internal.examples.ThreeWayMerge.doTheirsProjectEdit';
    baseProjectEditFcn='slxmlcomp.internal.examples.ThreeWayMerge.doBaseProjectEdit';

    import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.threeway.DemoConflictCreator;

    conflictCreator=DemoConflictCreator(...
    mineProjectEditFcn,...
    theirsProjectEditFcn,...
    baseProjectEditFcn,...
projectRoot...
    );
    conflictCreator.createConflict();

    import slxmlcomp.internal.examples.ThreeWayMerge;
    conflictedFile=ThreeWayMerge.getConflictedFile(projectRoot);
    matlab.internal.project.util.showFilesInProject(proj,conflictedFile);

end


