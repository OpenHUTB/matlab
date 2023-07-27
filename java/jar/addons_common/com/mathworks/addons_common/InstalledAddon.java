// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstalledAddon.java

package com.mathworks.addons_common;

import com.mathworks.addons_common.util.AddonManagerUtils;
import com.mathworks.util.Log;
import com.mathworks.util.ThreadUtils;
import java.awt.image.BufferedImage;
import java.nio.file.Path;
import java.util.*;
import java.util.concurrent.*;

// Referenced classes of package com.mathworks.addons_common:
//            ExplorerInstalledAddOnMetadata, ManagerInstalledAddOnMetadata, AdditionalAction, AddonCustomMetadata, 
//            DocumentationProvider

public final class InstalledAddon
    implements Comparable
{
    public static class Builder
    {

        public Builder displayType(String s)
        {
            displayType = s;
            return this;
        }

        public Builder installedDate(Date date)
        {
            installedDate = new Date(date.getTime());
            return this;
        }

        public Builder installationIdentifier(String s)
        {
            installationIdentifier = s;
            return this;
        }

        /**
         * @deprecated Method image is deprecated
         */

        public Builder image(final BufferedImage image)
        {
            imageProvider = new Callable() {

                public BufferedImage call()
                    throws Exception
                {
                    return image;
                }

                public volatile Object call()
                    throws Exception
                {
                    return call();
                }

                final BufferedImage val$image;
                final Builder this$0;

                
                {
                    this$0 = Builder.this;
                    image = bufferedimage;
                    super();
                }
            }
;
            return this;
        }

        public Builder imageProvider(Callable callable)
        {
            imageProvider = callable;
            return this;
        }

        public Builder isMathWorksSupported(boolean flag)
        {
            isMathworksSupported = flag;
            return this;
        }

        public Builder canUninstall(boolean flag)
        {
            canUninstall = flag;
            return this;
        }

        public Builder description(String s)
        {
            description = s;
            return this;
        }

        public Builder summary(String s)
        {
            summary = s;
            return this;
        }

        public Builder fileName(String as[])
        {
            fileName = (String[])Arrays.copyOf(as, as.length);
            return this;
        }

        public Builder absoluteFilePath(String as[])
        {
            absoluteFilePath = (String[])Arrays.copyOf(as, as.length);
            return this;
        }

        public Builder trialDaysRemaining(int i)
        {
            trialDaysRemaining = i;
            return this;
        }

        public Builder trial(boolean flag)
        {
            trial = flag;
            return this;
        }

        public Builder hasDetailPage(boolean flag)
        {
            hasDetailPage = flag;
            return this;
        }

        public Builder relatedAddOnIdentifiers(String as[])
        {
            relatedAddOnIdentifiers = as;
            return this;
        }

        public Builder relatedAddOnNames(String as[])
        {
            relatedAddOnNames = as;
            return this;
        }

        public Builder additionalAction(AdditionalAction additionalaction)
        {
            if(additionalActions.size() > 0)
            {
                throw new UnsupportedOperationException("An Additional Action has already been added, currently one additional Action could be added for an Add-On.");
            } else
            {
                additionalActions.add(additionalaction);
                return this;
            }
        }

        public Builder documentationProvider(DocumentationProvider documentationprovider)
        {
            documentationProvider = documentationprovider;
            return this;
        }

        public Builder installedFolder(Path path)
        {
            installedFolder = path;
            return this;
        }

        public Builder customMetadata(String s, AddonCustomMetadata addoncustommetadata)
        {
            if(customMetadataMap.containsKey(s))
            {
                throw new RuntimeException((new StringBuilder()).append("Metadata already exists for this add-on with attribute name : ").append(s).toString());
            } else
            {
                customMetadataMap.put(s, addoncustommetadata);
                return this;
            }
        }

        public Builder enabled(boolean flag)
        {
            enabled = flag;
            return this;
        }

        public Builder enableDisableSupported(boolean flag)
        {
            enableDisableSupported = flag;
            return this;
        }

        public InstalledAddon createInstalledAddon()
        {
            return new InstalledAddon(this);
        }

        private String type;
        private String identifier;
        private String name;
        private String version;
        private String author;
        private String installationIdentifier;
        private String displayType;
        private Date installedDate;
        private Callable imageProvider = new Callable() {

            public BufferedImage call()
                throws Exception
            {
                return AddonManagerUtils.BLANK_IMAGE;
            }

            public volatile Object call()
                throws Exception
            {
                return call();
            }

            final Builder this$0;

                
                {
                    this$0 = Builder.this;
                    super();
                }
        }
;
        private boolean isMathworksSupported;
        private boolean canUninstall;
        private String description;
        private String summary;
        private String fileName[];
        private String absoluteFilePath[];
        private int trialDaysRemaining;
        private boolean trial;
        private Path installedFolder;
        private boolean hasDetailPage;
        private String relatedAddOnIdentifiers[];
        private String relatedAddOnNames[];
        private Collection additionalActions;
        private DocumentationProvider documentationProvider;
        private HashMap customMetadataMap;
        private boolean enabled;
        private boolean enableDisableSupported;



























        /**
         * @deprecated Method Builder is deprecated
         */

        public Builder(String s, String s1, String s2, String s3, String s4)
        {
            installationIdentifier = "";
            displayType = "";
            installedDate = null;
            isMathworksSupported = false;
            canUninstall = true;
            description = "";
            summary = "";
            fileName = new String[0];
            absoluteFilePath = new String[0];
            trialDaysRemaining = 0;
            trial = false;
            installedFolder = null;
            hasDetailPage = false;
            relatedAddOnIdentifiers = new String[0];
            relatedAddOnNames = new String[0];
            additionalActions = new ArrayList();
            documentationProvider = null;
            customMetadataMap = new HashMap();
            enabled = true;
            enableDisableSupported = false;
            type = s;
            identifier = s1;
            name = s2;
            version = s3;
            author = s4;
        }

        public Builder(String s, String s1, String s2, String s3, String s4, String s5)
        {
            installationIdentifier = "";
            displayType = "";
            installedDate = null;
            isMathworksSupported = false;
            canUninstall = true;
            description = "";
            summary = "";
            fileName = new String[0];
            absoluteFilePath = new String[0];
            trialDaysRemaining = 0;
            trial = false;
            installedFolder = null;
            hasDetailPage = false;
            relatedAddOnIdentifiers = new String[0];
            relatedAddOnNames = new String[0];
            additionalActions = new ArrayList();
            documentationProvider = null;
            customMetadataMap = new HashMap();
            enabled = true;
            enableDisableSupported = false;
            type = s;
            identifier = s1;
            name = s2;
            version = s3;
            author = s4;
            installationIdentifier = s5;
        }
    }


    /**
     * @deprecated Method getBuilder is deprecated
     */

    public static Builder getBuilder(String s, String s1, String s2, String s3, String s4)
    {
        return new Builder(s, s1, s2, s3, s4);
    }

    public static Builder getBuilder(String s, String s1, String s2, String s3, String s4, String s5)
    {
        return new Builder(s, s1, s2, s3, s4, s5);
    }

    private InstalledAddon(Builder builder)
    {
        type = builder.type;
        if(builder.displayType.isEmpty())
            displayType = type;
        else
            displayType = builder.displayType;
        identifier = builder.identifier;
        name = builder.name;
        version = builder.version;
        author = builder.author;
        installedDate = builder.installedDate;
        installationIdentifier = builder.installationIdentifier;
        imageProvider = builder.imageProvider;
        isMathworksSupported = builder.isMathworksSupported;
        canUninstall = builder.canUninstall;
        description = builder.description;
        summary = builder.summary;
        fileName = builder.fileName;
        absoluteFilePath = builder.absoluteFilePath;
        trialDaysRemaining = builder.trialDaysRemaining;
        trial = builder.trial;
        hasDetailPage = builder.hasDetailPage;
        relatedAddOnIdentifiers = builder.relatedAddOnIdentifiers;
        relatedAddOnNames = builder.relatedAddOnNames;
        additionalActions = builder.additionalActions;
        documentationProvider = builder.documentationProvider;
        installedFolder = builder.installedFolder;
        customMetadataMap = builder.customMetadataMap;
        enabled = builder.enabled;
        enableDisableSupported = builder.enableDisableSupported;
    }

    public String getIdentifier()
    {
        return identifier;
    }

    public Date getInstalledDate()
    {
        return installedDate;
    }

    public String getInstallationIdentifier()
    {
        return installationIdentifier;
    }

    public ExplorerInstalledAddOnMetadata getInstalledAddOnsMetadataToBeSentToExplorer()
    {
        boolean flag = hasDocumentation();
        return new ExplorerInstalledAddOnMetadata(type, identifier, version, installedDate, trialDaysRemaining, trial, flag);
    }

    boolean hasDocumentation()
    {
        return documentationProvider != null;
    }

    /**
     * @deprecated Method getInstalledAddOnsMetadataToBeSentToManager is deprecated
     */

    public ManagerInstalledAddOnMetadata getInstalledAddOnsMetadataToBeSentToManager()
    {
        String as[] = getCustomActionNames();
        boolean flag = hasDocumentation();
        BufferedImage bufferedimage = getImage();
        return new ManagerInstalledAddOnMetadata(type, displayType, identifier, version, installationIdentifier, installedDate, name, author, bufferedimage, isMathworksSupported, canUninstall, description, summary, fileName, absoluteFilePath, canOpenFolder(), hasDetailPage, trialDaysRemaining, trial, relatedAddOnIdentifiers, relatedAddOnNames, as, flag, enabled, enableDisableSupported);
    }

    String[] getCustomActionNames()
    {
        ArrayList arraylist = new ArrayList();
        if(!additionalActions.isEmpty())
        {
            AdditionalAction additionalaction;
            for(Iterator iterator = additionalActions.iterator(); iterator.hasNext(); arraylist.add(additionalaction.getName()))
                additionalaction = (AdditionalAction)iterator.next();

        }
        return (String[])arraylist.toArray(new String[arraylist.size()]);
    }

    public BufferedImage getImage()
    {
        try
        {
            if(image == null)
                retrieveImageAsynchronously();
            return (BufferedImage)image.get();
        }
        catch(Exception exception)
        {
            Log.logException(exception);
        }
        return AddonManagerUtils.getBlankImage();
    }

    public boolean equals(Object obj)
    {
        if(!(obj instanceof InstalledAddon))
        {
            return false;
        } else
        {
            InstalledAddon installedaddon = (InstalledAddon)obj;
            return getIdentifier().equalsIgnoreCase(installedaddon.getIdentifier()) && getVersion().equalsIgnoreCase(installedaddon.getVersion());
        }
    }

    public int compareTo(InstalledAddon installedaddon)
    {
        String s = getName();
        String s1 = installedaddon.getName();
        return s.compareToIgnoreCase(s1);
    }

    public String getType()
    {
        return type;
    }

    String getDisplayType()
    {
        return displayType;
    }

    public String getAuthor()
    {
        return author;
    }

    boolean isMathworksSupported()
    {
        return isMathworksSupported;
    }

    public String getSummary()
    {
        return summary;
    }

    String[] getFileName()
    {
        return fileName;
    }

    String[] getAbsoluteFilePath()
    {
        return absoluteFilePath;
    }

    int getTrialDaysRemaining()
    {
        return trialDaysRemaining;
    }

    public boolean canOpenFolder()
    {
        return installedFolder != null;
    }

    public Path getInstalledFolder()
    {
        return installedFolder;
    }

    boolean isTrial()
    {
        return trial;
    }

    boolean hasDetailPage()
    {
        return hasDetailPage;
    }

    public String[] getRelatedAddOnIdentifiers()
    {
        return relatedAddOnIdentifiers;
    }

    public String[] getRelatedAddOnNames()
    {
        return relatedAddOnNames;
    }

    boolean canUninstall()
    {
        return canUninstall;
    }

    public String getDescription()
    {
        return description;
    }

    public String getName()
    {
        return name;
    }

    public String getVersion()
    {
        return version;
    }

    public AdditionalAction[] getAdditionalActions()
    {
        return (AdditionalAction[])additionalActions.toArray(new AdditionalAction[additionalActions.size()]);
    }

    public boolean hasCustomMetadataWithAttributeName(String s)
    {
        return customMetadataMap.containsKey(s);
    }

    public AddonCustomMetadata getCustomMetadataWithAttributeName(String s)
    {
        if(hasCustomMetadataWithAttributeName(s))
            return (AddonCustomMetadata)customMetadataMap.get(s);
        else
            throw new RuntimeException((new StringBuilder()).append("No custom metadata found with attribute name : ").append(s).toString());
    }

    public boolean isEnabled()
    {
        return enabled;
    }

    public boolean isEnableDisableSupported()
    {
        return enableDisableSupported;
    }

    public void setEnabled(boolean flag)
    {
        enabled = flag;
    }

    public DocumentationProvider getDocumentationProvider()
    {
        return documentationProvider;
    }

    public void retrieveImageAsynchronously()
    {
        ExecutorService executorservice = ThreadUtils.newSingleDaemonThreadExecutor((new StringBuilder()).append(com/mathworks/addons_common/InstalledAddon.getName()).append("for Add-On ").append(name).toString());
        image = executorservice.submit(imageProvider);
        executorservice.shutdown();
    }

    public volatile int compareTo(Object obj)
    {
        return compareTo((InstalledAddon)obj);
    }


    private final String type;
    private final String displayType;
    private final String identifier;
    private final String name;
    private final String version;
    private final String author;
    private final Date installedDate;
    private final String installationIdentifier;
    private Future image;
    private final boolean isMathworksSupported;
    private final boolean canUninstall;
    private final Path installedFolder;
    private final String description;
    private final String summary;
    private String fileName[];
    private String absoluteFilePath[];
    private final int trialDaysRemaining;
    private final boolean trial;
    private final boolean hasDetailPage;
    private final String relatedAddOnIdentifiers[];
    private final String relatedAddOnNames[];
    private Callable imageProvider;
    private final Collection additionalActions;
    private final DocumentationProvider documentationProvider;
    private final HashMap customMetadataMap;
    private boolean enabled;
    private final boolean enableDisableSupported;
}
