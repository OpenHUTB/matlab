function CopyFromBackup(classObj)




    factory=evolutions.internal.session.SessionManager.getVisitorFactory;
    visitor=factory.getVisitor('CopyFromBackup');
    evolutions.internal.classhandler.ClassHandler.visitObjects(classObj,visitor);
end
