function DeleteObjectBackup(classObj)




    factory=evolutions.internal.session.SessionManager.getVisitorFactory;
    visitor=factory.getVisitor('DeleteBackup');
    evolutions.internal.classhandler.ClassHandler.visitObjects(classObj,visitor);
end
