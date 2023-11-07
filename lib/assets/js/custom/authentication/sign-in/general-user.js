"use strict";

// Class definition
var KTSigninGeneralUser = function () {
    // Elements
    var form;
    var submitButton;
    var validator;

    // Handle form
    var handleValidation = function (e) {        
        // Init form validation rules. For more info check the FormValidation plugin's official documentation:https://formvalidation.io/
        validator = FormValidation.formValidation(
            form,
            {
                fields: {
                    'otp[email]': {
                        validators: {
                            regexp: {
                                regexp: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
                                message: 'Ingresa un email válido',
                            },
                            notEmpty: {
                                message: 'Email es requerido'
                            }
                        }
                    }
                },
                plugins: {
                    trigger: new FormValidation.plugins.Trigger(),
                    bootstrap: new FormValidation.plugins.Bootstrap5({
                        rowSelector: '.fv-row',
                        eleInvalidClass: '',  // comment to enable invalid state icons
                        eleValidClass: '' // comment to enable valid state icons
                    })
                }
            }
        );
    }

    var handleSubmit = function (e) {
        // Handle form submit
        submitButton.addEventListener('click', function (e) {
            // Prevent button default action
            e.preventDefault();

            // Validate form
            validator.validate().then(function (status) {
                if (status == 'Valid') {
                    // Show loading indication
                    submitButton.setAttribute('data-kt-indicator', 'on');

                    // Disable button to avoid multiple click
                    submitButton.disabled = true;

                    // Envia el formulario
                    form.submit();
                    
                } else {
                    // Show error popup. For more info check the plugin's official documentation: https://sweetalert2.github.io/
                    Swal.fire({
                        text: "Debe ingresar un correo electrónico",
                        icon: "error",
                        buttonsStyling: false,
                        confirmButtonText: "Entendido",
                        customClass: {
                            confirmButton: "btn btn-primary"
                        }
                    });
                }
            });
        });
    }

    // Public functions
    return {
        // Initialization
        init: function () {
            form = document.querySelector('#kt_sign_in_user_form');
            submitButton = document.querySelector('#kt_sign_in_user_submit');

            handleValidation();
            handleSubmit();
        }
    };
}();

// On document ready
KTUtil.onDOMContentLoaded(function () {
    KTSigninGeneralUser.init();
});

function onSuccessRecaptchaVerification() {
    var btn = document.querySelector("#kt_sign_in_user_submit");
    btn.removeAttribute('disabled');
}


function onErrorRecaptchaVerification() {
    var btn = document.querySelector("#kt_sign_in_user_submit");
    var form = document.querySelector("#kt_sign_in_user_form");
    btn.addAttribute('disabled', 'disabled');
    form.reset();
}


function onExpireRecaptchaVerification() {
    var btn = document.querySelector("#kt_sign_in_user_submit");
    var form = document.querySelector("#kt_sign_in_user_form");
    btn.addAttribute('disabled', 'disabled');
    form.reset();
}


window.onSuccessRecaptchaVerification = onSuccessRecaptchaVerification
window.onErrorRecaptchaVerification = onErrorRecaptchaVerification
window.onExpireRecaptchaVerification = onExpireRecaptchaVerification