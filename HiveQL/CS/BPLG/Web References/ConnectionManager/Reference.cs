﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

// 
// This source code was auto-generated by Microsoft.VSDesigner, Version 4.0.30319.42000.
// 
#pragma warning disable 1591

namespace BPLG.ConnectionManager {
    using System;
    using System.Web.Services;
    using System.Diagnostics;
    using System.Web.Services.Protocols;
    using System.Xml.Serialization;
    using System.ComponentModel;
    
    
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Web.Services", "4.6.1055.0")]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Web.Services.WebServiceBindingAttribute(Name="Configuration_ManagerSoap", Namespace="Configuration_Manager")]
    public partial class Configuration_Manager : System.Web.Services.Protocols.SoapHttpClientProtocol {
        
        private System.Threading.SendOrPostCallback GetConnectionStringOperationCompleted;
        
        private System.Threading.SendOrPostCallback GetNavigationStringOperationCompleted;
        
        private bool useDefaultCredentialsSetExplicitly;
        
        /// <remarks/>
        public Configuration_Manager() {
            this.Url = global::BPLG.Properties.Settings.Default.BPLG_ConnectionManager_ConnectionManager;
            if ((this.IsLocalFileSystemWebService(this.Url) == true)) {
                this.UseDefaultCredentials = true;
                this.useDefaultCredentialsSetExplicitly = false;
            }
            else {
                this.useDefaultCredentialsSetExplicitly = true;
            }
        }
        
        public new string Url {
            get {
                return base.Url;
            }
            set {
                if ((((this.IsLocalFileSystemWebService(base.Url) == true) 
                            && (this.useDefaultCredentialsSetExplicitly == false)) 
                            && (this.IsLocalFileSystemWebService(value) == false))) {
                    base.UseDefaultCredentials = false;
                }
                base.Url = value;
            }
        }
        
        public new bool UseDefaultCredentials {
            get {
                return base.UseDefaultCredentials;
            }
            set {
                base.UseDefaultCredentials = value;
                this.useDefaultCredentialsSetExplicitly = true;
            }
        }
        
        /// <remarks/>
        public event GetConnectionStringCompletedEventHandler GetConnectionStringCompleted;
        
        /// <remarks/>
        public event GetNavigationStringCompletedEventHandler GetNavigationStringCompleted;
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapDocumentMethodAttribute("Configuration_Manager/GetConnectionString", RequestNamespace="Configuration_Manager", ResponseNamespace="Configuration_Manager", Use=System.Web.Services.Description.SoapBindingUse.Literal, ParameterStyle=System.Web.Services.Protocols.SoapParameterStyle.Wrapped)]
        public string GetConnectionString(string ApplicationName, string DatabaseName) {
            object[] results = this.Invoke("GetConnectionString", new object[] {
                        ApplicationName,
                        DatabaseName});
            return ((string)(results[0]));
        }
        
        /// <remarks/>
        public void GetConnectionStringAsync(string ApplicationName, string DatabaseName) {
            this.GetConnectionStringAsync(ApplicationName, DatabaseName, null);
        }
        
        /// <remarks/>
        public void GetConnectionStringAsync(string ApplicationName, string DatabaseName, object userState) {
            if ((this.GetConnectionStringOperationCompleted == null)) {
                this.GetConnectionStringOperationCompleted = new System.Threading.SendOrPostCallback(this.OnGetConnectionStringOperationCompleted);
            }
            this.InvokeAsync("GetConnectionString", new object[] {
                        ApplicationName,
                        DatabaseName}, this.GetConnectionStringOperationCompleted, userState);
        }
        
        private void OnGetConnectionStringOperationCompleted(object arg) {
            if ((this.GetConnectionStringCompleted != null)) {
                System.Web.Services.Protocols.InvokeCompletedEventArgs invokeArgs = ((System.Web.Services.Protocols.InvokeCompletedEventArgs)(arg));
                this.GetConnectionStringCompleted(this, new GetConnectionStringCompletedEventArgs(invokeArgs.Results, invokeArgs.Error, invokeArgs.Cancelled, invokeArgs.UserState));
            }
        }
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapDocumentMethodAttribute("Configuration_Manager/GetNavigationString", RequestNamespace="Configuration_Manager", ResponseNamespace="Configuration_Manager", Use=System.Web.Services.Description.SoapBindingUse.Literal, ParameterStyle=System.Web.Services.Protocols.SoapParameterStyle.Wrapped)]
        public string GetNavigationString(string PlaceHolder) {
            object[] results = this.Invoke("GetNavigationString", new object[] {
                        PlaceHolder});
            return ((string)(results[0]));
        }
        
        /// <remarks/>
        public void GetNavigationStringAsync(string PlaceHolder) {
            this.GetNavigationStringAsync(PlaceHolder, null);
        }
        
        /// <remarks/>
        public void GetNavigationStringAsync(string PlaceHolder, object userState) {
            if ((this.GetNavigationStringOperationCompleted == null)) {
                this.GetNavigationStringOperationCompleted = new System.Threading.SendOrPostCallback(this.OnGetNavigationStringOperationCompleted);
            }
            this.InvokeAsync("GetNavigationString", new object[] {
                        PlaceHolder}, this.GetNavigationStringOperationCompleted, userState);
        }
        
        private void OnGetNavigationStringOperationCompleted(object arg) {
            if ((this.GetNavigationStringCompleted != null)) {
                System.Web.Services.Protocols.InvokeCompletedEventArgs invokeArgs = ((System.Web.Services.Protocols.InvokeCompletedEventArgs)(arg));
                this.GetNavigationStringCompleted(this, new GetNavigationStringCompletedEventArgs(invokeArgs.Results, invokeArgs.Error, invokeArgs.Cancelled, invokeArgs.UserState));
            }
        }
        
        /// <remarks/>
        public new void CancelAsync(object userState) {
            base.CancelAsync(userState);
        }
        
        private bool IsLocalFileSystemWebService(string url) {
            if (((url == null) 
                        || (url == string.Empty))) {
                return false;
            }
            System.Uri wsUri = new System.Uri(url);
            if (((wsUri.Port >= 1024) 
                        && (string.Compare(wsUri.Host, "localHost", System.StringComparison.OrdinalIgnoreCase) == 0))) {
                return true;
            }
            return false;
        }
    }
    
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Web.Services", "4.6.1055.0")]
    public delegate void GetConnectionStringCompletedEventHandler(object sender, GetConnectionStringCompletedEventArgs e);
    
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Web.Services", "4.6.1055.0")]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    public partial class GetConnectionStringCompletedEventArgs : System.ComponentModel.AsyncCompletedEventArgs {
        
        private object[] results;
        
        internal GetConnectionStringCompletedEventArgs(object[] results, System.Exception exception, bool cancelled, object userState) : 
                base(exception, cancelled, userState) {
            this.results = results;
        }
        
        /// <remarks/>
        public string Result {
            get {
                this.RaiseExceptionIfNecessary();
                return ((string)(this.results[0]));
            }
        }
    }
    
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Web.Services", "4.6.1055.0")]
    public delegate void GetNavigationStringCompletedEventHandler(object sender, GetNavigationStringCompletedEventArgs e);
    
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Web.Services", "4.6.1055.0")]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    public partial class GetNavigationStringCompletedEventArgs : System.ComponentModel.AsyncCompletedEventArgs {
        
        private object[] results;
        
        internal GetNavigationStringCompletedEventArgs(object[] results, System.Exception exception, bool cancelled, object userState) : 
                base(exception, cancelled, userState) {
            this.results = results;
        }
        
        /// <remarks/>
        public string Result {
            get {
                this.RaiseExceptionIfNecessary();
                return ((string)(this.results[0]));
            }
        }
    }
}

#pragma warning restore 1591