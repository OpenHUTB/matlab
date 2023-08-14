// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   GetSoftwareProductInfoByLicenseAndArchitecturesReturn.java

package com.mathworks.internal.dws.client.v3;

import java.util.ArrayList;
import java.util.Vector;
import javax.xml.namespace.NamespaceContext;
import javax.xml.namespace.QName;
import javax.xml.stream.*;
import org.apache.axiom.om.OMElement;
import org.apache.axiom.om.OMFactory;
import org.apache.axiom.om.impl.llom.OMSourcedElementImpl;
import org.apache.axis2.databinding.*;
import org.apache.axis2.databinding.utils.BeanUtil;
import org.apache.axis2.databinding.utils.ConverterUtil;
import org.apache.axis2.databinding.utils.reader.ADBXMLStreamReaderImpl;
import org.apache.axis2.databinding.utils.writer.MTOMAwareXMLStreamWriter;

// Referenced classes of package com.mathworks.internal.dws.client.v3:
//            ArrayOfArchitecture, ArrayOfSoftwareProductComponent, ArrayOfRelationship, ArrayOfSoftwareProduct, 
//            ArrayOfSoftwareLicense, ArrayOfServer, ArrayOfMWMessage, ArrayOfError, 
//            ExtensionMapper

public class GetSoftwareProductInfoByLicenseAndArchitecturesReturn
    implements ADBBean
{
    public static class Factory
    {

        public static GetSoftwareProductInfoByLicenseAndArchitecturesReturn parse(XMLStreamReader reader)
            throws Exception
        {
            GetSoftwareProductInfoByLicenseAndArchitecturesReturn object;
            object = new GetSoftwareProductInfoByLicenseAndArchitecturesReturn();
            String nillableValue = null;
            String prefix = "";
            String namespaceuri = "";
            Vector handledAttributes;
            String content;
            try
            {
                for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
                if(reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "type") != null)
                {
                    String fullTypeName = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "type");
                    if(fullTypeName != null)
                    {
                        String nsPrefix = null;
                        if(fullTypeName.indexOf(":") > -1)
                            nsPrefix = fullTypeName.substring(0, fullTypeName.indexOf(":"));
                        nsPrefix = nsPrefix != null ? nsPrefix : "";
                        String type = fullTypeName.substring(fullTypeName.indexOf(":") + 1);
                        if(!"getSoftwareProductInfoByLicenseAndArchitecturesReturn".equals(type))
                        {
                            String nsUri = reader.getNamespaceContext().getNamespaceURI(nsPrefix);
                            return (GetSoftwareProductInfoByLicenseAndArchitecturesReturn)ExtensionMapper.getTypeObject(nsUri, type, reader);
                        }
                    }
                }
            }
            catch(XMLStreamException e)
            {
                throw new Exception(e);
            }
            handledAttributes = new Vector();
            reader.next();
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "allArchitectures")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if("true".equals(nillableValue) || "1".equals(nillableValue))
                {
                    object.setAllArchitectures(null);
                    reader.next();
                    reader.next();
                } else
                {
                    object.setAllArchitectures(ArrayOfArchitecture.Factory.parse(reader));
                    reader.next();
                }
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "allComponents")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if("true".equals(nillableValue) || "1".equals(nillableValue))
                {
                    object.setAllComponents(null);
                    reader.next();
                    reader.next();
                } else
                {
                    object.setAllComponents(ArrayOfSoftwareProductComponent.Factory.parse(reader));
                    reader.next();
                }
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "allRelationships")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if("true".equals(nillableValue) || "1".equals(nillableValue))
                {
                    object.setAllRelationships(null);
                    reader.next();
                    reader.next();
                } else
                {
                    object.setAllRelationships(ArrayOfRelationship.Factory.parse(reader));
                    reader.next();
                }
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "allSoftwareProducts")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if("true".equals(nillableValue) || "1".equals(nillableValue))
                {
                    object.setAllSoftwareProducts(null);
                    reader.next();
                    reader.next();
                } else
                {
                    object.setAllSoftwareProducts(ArrayOfSoftwareProduct.Factory.parse(reader));
                    reader.next();
                }
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "licenses")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if("true".equals(nillableValue) || "1".equals(nillableValue))
                {
                    object.setLicenses(null);
                    reader.next();
                    reader.next();
                } else
                {
                    object.setLicenses(ArrayOfSoftwareLicense.Factory.parse(reader));
                    reader.next();
                }
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "servers")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if("true".equals(nillableValue) || "1".equals(nillableValue))
                {
                    object.setServers(null);
                    reader.next();
                    reader.next();
                } else
                {
                    object.setServers(ArrayOfServer.Factory.parse(reader));
                    reader.next();
                }
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "token")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if(!"true".equals(nillableValue) && !"1".equals(nillableValue))
                {
                    content = reader.getElementText();
                    object.setToken(ConverterUtil.convertToString(content));
                } else
                {
                    reader.getElementText();
                }
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "result")).equals(reader.getName()))
            {
                content = reader.getElementText();
                object.setResult(ConverterUtil.convertToInt(content));
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "messages")).equals(reader.getName()))
            {
                object.setMessages(ArrayOfMWMessage.Factory.parse(reader));
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "errors")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if("true".equals(nillableValue) || "1".equals(nillableValue))
                {
                    object.setErrors(null);
                    reader.next();
                    reader.next();
                } else
                {
                    object.setErrors(ArrayOfError.Factory.parse(reader));
                    reader.next();
                }
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement())
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            return object;
        }

        public Factory()
        {
        }
    }


    public GetSoftwareProductInfoByLicenseAndArchitecturesReturn()
    {
    }

    private static String generatePrefix(String namespace)
    {
        if(namespace.equals("https://services.mathworks.com/dws3/services/DownloadService"))
            return "ns1";
        else
            return BeanUtil.getUniquePrefix();
    }

    public ArrayOfArchitecture getAllArchitectures()
    {
        return localAllArchitectures;
    }

    public void setAllArchitectures(ArrayOfArchitecture param)
    {
        localAllArchitectures = param;
    }

    public ArrayOfSoftwareProductComponent getAllComponents()
    {
        return localAllComponents;
    }

    public void setAllComponents(ArrayOfSoftwareProductComponent param)
    {
        localAllComponents = param;
    }

    public ArrayOfRelationship getAllRelationships()
    {
        return localAllRelationships;
    }

    public void setAllRelationships(ArrayOfRelationship param)
    {
        localAllRelationships = param;
    }

    public ArrayOfSoftwareProduct getAllSoftwareProducts()
    {
        return localAllSoftwareProducts;
    }

    public void setAllSoftwareProducts(ArrayOfSoftwareProduct param)
    {
        localAllSoftwareProducts = param;
    }

    public ArrayOfSoftwareLicense getLicenses()
    {
        return localLicenses;
    }

    public void setLicenses(ArrayOfSoftwareLicense param)
    {
        localLicenses = param;
    }

    public ArrayOfServer getServers()
    {
        return localServers;
    }

    public void setServers(ArrayOfServer param)
    {
        localServers = param;
    }

    public String getToken()
    {
        return localToken;
    }

    public void setToken(String param)
    {
        localToken = param;
    }

    public int getResult()
    {
        return localResult;
    }

    public void setResult(int param)
    {
        localResult = param;
    }

    public ArrayOfMWMessage getMessages()
    {
        return localMessages;
    }

    public void setMessages(ArrayOfMWMessage param)
    {
        localMessages = param;
    }

    public ArrayOfError getErrors()
    {
        return localErrors;
    }

    public void setErrors(ArrayOfError param)
    {
        localErrors = param;
    }

    public static boolean isReaderMTOMAware(XMLStreamReader reader)
    {
        boolean isReaderMTOMAware = false;
        try
        {
            isReaderMTOMAware = Boolean.TRUE.equals(reader.getProperty("IsDatahandlersAwareParsing"));
        }
        catch(IllegalArgumentException e)
        {
            isReaderMTOMAware = false;
        }
        return isReaderMTOMAware;
    }

    public OMElement getOMElement(QName parentQName, OMFactory factory)
        throws ADBException
    {
        org.apache.axiom.om.OMDataSource dataSource = new ADBDataSource(parentQName, factory) {

            public void serialize(MTOMAwareXMLStreamWriter xmlWriter)
                throws XMLStreamException
            {
                GetSoftwareProductInfoByLicenseAndArchitecturesReturn.this.serialize(parentQName, factory, xmlWriter);
            }

            final OMFactory val$factory;
            final GetSoftwareProductInfoByLicenseAndArchitecturesReturn this$0;

            
            {
                this$0 = GetSoftwareProductInfoByLicenseAndArchitecturesReturn.this;
                factory = omfactory;
                super(x0, x1);
            }
        }
;
        return new OMSourcedElementImpl(parentQName, factory, dataSource);
    }

    public void serialize(QName parentQName, OMFactory factory, MTOMAwareXMLStreamWriter xmlWriter)
        throws XMLStreamException, ADBException
    {
        serialize(parentQName, factory, xmlWriter, false);
    }

    public void serialize(QName parentQName, OMFactory factory, MTOMAwareXMLStreamWriter xmlWriter, boolean serializeType)
        throws XMLStreamException, ADBException
    {
        String prefix = null;
        String namespace = null;
        prefix = parentQName.getPrefix();
        namespace = parentQName.getNamespaceURI();
        if(namespace != null && namespace.trim().length() > 0)
        {
            String writerPrefix = xmlWriter.getPrefix(namespace);
            if(writerPrefix != null)
            {
                xmlWriter.writeStartElement(namespace, parentQName.getLocalPart());
            } else
            {
                if(prefix == null)
                    prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, parentQName.getLocalPart(), namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            }
        } else
        {
            xmlWriter.writeStartElement(parentQName.getLocalPart());
        }
        if(serializeType)
        {
            String namespacePrefix = registerPrefix(xmlWriter, "https://services.mathworks.com/dws3/services/DownloadService");
            if(namespacePrefix != null && namespacePrefix.trim().length() > 0)
                writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "type", (new StringBuilder()).append(namespacePrefix).append(":getSoftwareProductInfoByLicenseAndArchitecturesReturn").toString(), xmlWriter);
            else
                writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "type", "getSoftwareProductInfoByLicenseAndArchitecturesReturn", xmlWriter);
        }
        if(localAllArchitectures == null)
        {
            String namespace2 = "https://services.mathworks.com/dws3/services/DownloadService";
            if(!namespace2.equals(""))
            {
                String prefix2 = xmlWriter.getPrefix(namespace2);
                if(prefix2 == null)
                {
                    prefix2 = generatePrefix(namespace2);
                    xmlWriter.writeStartElement(prefix2, "allArchitectures", namespace2);
                    xmlWriter.writeNamespace(prefix2, namespace2);
                    xmlWriter.setPrefix(prefix2, namespace2);
                } else
                {
                    xmlWriter.writeStartElement(namespace2, "allArchitectures");
                }
            } else
            {
                xmlWriter.writeStartElement("allArchitectures");
            }
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
            xmlWriter.writeEndElement();
        } else
        {
            localAllArchitectures.serialize(new QName("https://services.mathworks.com/dws3/services/DownloadService", "allArchitectures"), factory, xmlWriter);
        }
        if(localAllComponents == null)
        {
            String namespace2 = "https://services.mathworks.com/dws3/services/DownloadService";
            if(!namespace2.equals(""))
            {
                String prefix2 = xmlWriter.getPrefix(namespace2);
                if(prefix2 == null)
                {
                    prefix2 = generatePrefix(namespace2);
                    xmlWriter.writeStartElement(prefix2, "allComponents", namespace2);
                    xmlWriter.writeNamespace(prefix2, namespace2);
                    xmlWriter.setPrefix(prefix2, namespace2);
                } else
                {
                    xmlWriter.writeStartElement(namespace2, "allComponents");
                }
            } else
            {
                xmlWriter.writeStartElement("allComponents");
            }
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
            xmlWriter.writeEndElement();
        } else
        {
            localAllComponents.serialize(new QName("https://services.mathworks.com/dws3/services/DownloadService", "allComponents"), factory, xmlWriter);
        }
        if(localAllRelationships == null)
        {
            String namespace2 = "https://services.mathworks.com/dws3/services/DownloadService";
            if(!namespace2.equals(""))
            {
                String prefix2 = xmlWriter.getPrefix(namespace2);
                if(prefix2 == null)
                {
                    prefix2 = generatePrefix(namespace2);
                    xmlWriter.writeStartElement(prefix2, "allRelationships", namespace2);
                    xmlWriter.writeNamespace(prefix2, namespace2);
                    xmlWriter.setPrefix(prefix2, namespace2);
                } else
                {
                    xmlWriter.writeStartElement(namespace2, "allRelationships");
                }
            } else
            {
                xmlWriter.writeStartElement("allRelationships");
            }
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
            xmlWriter.writeEndElement();
        } else
        {
            localAllRelationships.serialize(new QName("https://services.mathworks.com/dws3/services/DownloadService", "allRelationships"), factory, xmlWriter);
        }
        if(localAllSoftwareProducts == null)
        {
            String namespace2 = "https://services.mathworks.com/dws3/services/DownloadService";
            if(!namespace2.equals(""))
            {
                String prefix2 = xmlWriter.getPrefix(namespace2);
                if(prefix2 == null)
                {
                    prefix2 = generatePrefix(namespace2);
                    xmlWriter.writeStartElement(prefix2, "allSoftwareProducts", namespace2);
                    xmlWriter.writeNamespace(prefix2, namespace2);
                    xmlWriter.setPrefix(prefix2, namespace2);
                } else
                {
                    xmlWriter.writeStartElement(namespace2, "allSoftwareProducts");
                }
            } else
            {
                xmlWriter.writeStartElement("allSoftwareProducts");
            }
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
            xmlWriter.writeEndElement();
        } else
        {
            localAllSoftwareProducts.serialize(new QName("https://services.mathworks.com/dws3/services/DownloadService", "allSoftwareProducts"), factory, xmlWriter);
        }
        if(localLicenses == null)
        {
            String namespace2 = "https://services.mathworks.com/dws3/services/DownloadService";
            if(!namespace2.equals(""))
            {
                String prefix2 = xmlWriter.getPrefix(namespace2);
                if(prefix2 == null)
                {
                    prefix2 = generatePrefix(namespace2);
                    xmlWriter.writeStartElement(prefix2, "licenses", namespace2);
                    xmlWriter.writeNamespace(prefix2, namespace2);
                    xmlWriter.setPrefix(prefix2, namespace2);
                } else
                {
                    xmlWriter.writeStartElement(namespace2, "licenses");
                }
            } else
            {
                xmlWriter.writeStartElement("licenses");
            }
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
            xmlWriter.writeEndElement();
        } else
        {
            localLicenses.serialize(new QName("https://services.mathworks.com/dws3/services/DownloadService", "licenses"), factory, xmlWriter);
        }
        if(localServers == null)
        {
            String namespace2 = "https://services.mathworks.com/dws3/services/DownloadService";
            if(!namespace2.equals(""))
            {
                String prefix2 = xmlWriter.getPrefix(namespace2);
                if(prefix2 == null)
                {
                    prefix2 = generatePrefix(namespace2);
                    xmlWriter.writeStartElement(prefix2, "servers", namespace2);
                    xmlWriter.writeNamespace(prefix2, namespace2);
                    xmlWriter.setPrefix(prefix2, namespace2);
                } else
                {
                    xmlWriter.writeStartElement(namespace2, "servers");
                }
            } else
            {
                xmlWriter.writeStartElement("servers");
            }
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
            xmlWriter.writeEndElement();
        } else
        {
            localServers.serialize(new QName("https://services.mathworks.com/dws3/services/DownloadService", "servers"), factory, xmlWriter);
        }
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "token", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "token");
            }
        } else
        {
            xmlWriter.writeStartElement("token");
        }
        if(localToken == null)
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
        else
            xmlWriter.writeCharacters(localToken);
        xmlWriter.writeEndElement();
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "result", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "result");
            }
        } else
        {
            xmlWriter.writeStartElement("result");
        }
        if(localResult == 0x80000000)
            throw new ADBException("result cannot be null!!");
        xmlWriter.writeCharacters(ConverterUtil.convertToString(localResult));
        xmlWriter.writeEndElement();
        if(localMessages == null)
            throw new ADBException("messages cannot be null!!");
        localMessages.serialize(new QName("https://services.mathworks.com/dws3/services/DownloadService", "messages"), factory, xmlWriter);
        if(localErrors == null)
        {
            String namespace2 = "https://services.mathworks.com/dws3/services/DownloadService";
            if(!namespace2.equals(""))
            {
                String prefix2 = xmlWriter.getPrefix(namespace2);
                if(prefix2 == null)
                {
                    prefix2 = generatePrefix(namespace2);
                    xmlWriter.writeStartElement(prefix2, "errors", namespace2);
                    xmlWriter.writeNamespace(prefix2, namespace2);
                    xmlWriter.setPrefix(prefix2, namespace2);
                } else
                {
                    xmlWriter.writeStartElement(namespace2, "errors");
                }
            } else
            {
                xmlWriter.writeStartElement("errors");
            }
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
            xmlWriter.writeEndElement();
        } else
        {
            localErrors.serialize(new QName("https://services.mathworks.com/dws3/services/DownloadService", "errors"), factory, xmlWriter);
        }
        xmlWriter.writeEndElement();
    }

    private void writeAttribute(String prefix, String namespace, String attName, String attValue, XMLStreamWriter xmlWriter)
        throws XMLStreamException
    {
        if(xmlWriter.getPrefix(namespace) == null)
        {
            xmlWriter.writeNamespace(prefix, namespace);
            xmlWriter.setPrefix(prefix, namespace);
        }
        xmlWriter.writeAttribute(namespace, attName, attValue);
    }

    private void writeAttribute(String namespace, String attName, String attValue, XMLStreamWriter xmlWriter)
        throws XMLStreamException
    {
        if(namespace.equals(""))
        {
            xmlWriter.writeAttribute(attName, attValue);
        } else
        {
            registerPrefix(xmlWriter, namespace);
            xmlWriter.writeAttribute(namespace, attName, attValue);
        }
    }

    private void writeQNameAttribute(String namespace, String attName, QName qname, XMLStreamWriter xmlWriter)
        throws XMLStreamException
    {
        String attributeNamespace = qname.getNamespaceURI();
        String attributePrefix = xmlWriter.getPrefix(attributeNamespace);
        if(attributePrefix == null)
            attributePrefix = registerPrefix(xmlWriter, attributeNamespace);
        String attributeValue;
        if(attributePrefix.trim().length() > 0)
            attributeValue = (new StringBuilder()).append(attributePrefix).append(":").append(qname.getLocalPart()).toString();
        else
            attributeValue = qname.getLocalPart();
        if(namespace.equals(""))
        {
            xmlWriter.writeAttribute(attName, attributeValue);
        } else
        {
            registerPrefix(xmlWriter, namespace);
            xmlWriter.writeAttribute(namespace, attName, attributeValue);
        }
    }

    private void writeQName(QName qname, XMLStreamWriter xmlWriter)
        throws XMLStreamException
    {
        String namespaceURI = qname.getNamespaceURI();
        if(namespaceURI != null)
        {
            String prefix = xmlWriter.getPrefix(namespaceURI);
            if(prefix == null)
            {
                prefix = generatePrefix(namespaceURI);
                xmlWriter.writeNamespace(prefix, namespaceURI);
                xmlWriter.setPrefix(prefix, namespaceURI);
            }
            if(prefix.trim().length() > 0)
                xmlWriter.writeCharacters((new StringBuilder()).append(prefix).append(":").append(ConverterUtil.convertToString(qname)).toString());
            else
                xmlWriter.writeCharacters(ConverterUtil.convertToString(qname));
        } else
        {
            xmlWriter.writeCharacters(ConverterUtil.convertToString(qname));
        }
    }

    private void writeQNames(QName qnames[], XMLStreamWriter xmlWriter)
        throws XMLStreamException
    {
        if(qnames != null)
        {
            StringBuffer stringToWrite = new StringBuffer();
            String namespaceURI = null;
            String prefix = null;
            for(int i = 0; i < qnames.length; i++)
            {
                if(i > 0)
                    stringToWrite.append(" ");
                namespaceURI = qnames[i].getNamespaceURI();
                if(namespaceURI != null)
                {
                    prefix = xmlWriter.getPrefix(namespaceURI);
                    if(prefix == null || prefix.length() == 0)
                    {
                        prefix = generatePrefix(namespaceURI);
                        xmlWriter.writeNamespace(prefix, namespaceURI);
                        xmlWriter.setPrefix(prefix, namespaceURI);
                    }
                    if(prefix.trim().length() > 0)
                        stringToWrite.append(prefix).append(":").append(ConverterUtil.convertToString(qnames[i]));
                    else
                        stringToWrite.append(ConverterUtil.convertToString(qnames[i]));
                } else
                {
                    stringToWrite.append(ConverterUtil.convertToString(qnames[i]));
                }
            }

            xmlWriter.writeCharacters(stringToWrite.toString());
        }
    }

    private String registerPrefix(XMLStreamWriter xmlWriter, String namespace)
        throws XMLStreamException
    {
        String prefix = xmlWriter.getPrefix(namespace);
        if(prefix == null)
        {
            for(prefix = generatePrefix(namespace); xmlWriter.getNamespaceContext().getNamespaceURI(prefix) != null; prefix = BeanUtil.getUniquePrefix());
            xmlWriter.writeNamespace(prefix, namespace);
            xmlWriter.setPrefix(prefix, namespace);
        }
        return prefix;
    }

    public XMLStreamReader getPullParser(QName qName)
        throws ADBException
    {
        ArrayList elementList = new ArrayList();
        ArrayList attribList = new ArrayList();
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "allArchitectures"));
        elementList.add(localAllArchitectures != null ? ((Object) (localAllArchitectures)) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "allComponents"));
        elementList.add(localAllComponents != null ? ((Object) (localAllComponents)) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "allRelationships"));
        elementList.add(localAllRelationships != null ? ((Object) (localAllRelationships)) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "allSoftwareProducts"));
        elementList.add(localAllSoftwareProducts != null ? ((Object) (localAllSoftwareProducts)) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "licenses"));
        elementList.add(localLicenses != null ? ((Object) (localLicenses)) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "servers"));
        elementList.add(localServers != null ? ((Object) (localServers)) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "token"));
        elementList.add(localToken != null ? ((Object) (ConverterUtil.convertToString(localToken))) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "result"));
        elementList.add(ConverterUtil.convertToString(localResult));
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "messages"));
        if(localMessages == null)
        {
            throw new ADBException("messages cannot be null!!");
        } else
        {
            elementList.add(localMessages);
            elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "errors"));
            elementList.add(localErrors != null ? ((Object) (localErrors)) : null);
            return new ADBXMLStreamReaderImpl(qName, elementList.toArray(), attribList.toArray());
        }
    }

    protected ArrayOfArchitecture localAllArchitectures;
    protected ArrayOfSoftwareProductComponent localAllComponents;
    protected ArrayOfRelationship localAllRelationships;
    protected ArrayOfSoftwareProduct localAllSoftwareProducts;
    protected ArrayOfSoftwareLicense localLicenses;
    protected ArrayOfServer localServers;
    protected String localToken;
    protected int localResult;
    protected ArrayOfMWMessage localMessages;
    protected ArrayOfError localErrors;
}
