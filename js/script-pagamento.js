const paymentOptions = document.querySelectorAll('.payment-option');
        const creditCardForm = document.getElementById('credit-card-form');
        const pixForm = document.getElementById('pix-form');
        
        paymentOptions.forEach(option => {
            option.addEventListener('click', () => {
                // Remover a classe selecionada de todas as opções
                paymentOptions.forEach(opt => opt.classList.remove('selected'));
                
                // Adicionar a classe selecionada à opção clicada               
                
                // Obter o método de pagamento selecionado
                const selectedMethod = option.querySelector('input').value;
                
                // Mostrar/ocultar formulários com base na seleção
                if (selectedMethod === 'credit' || selectedMethod === 'debit') {
                    creditCardForm.style.display = 'block';
                    pixForm.style.display = 'none';
                } else {
                    creditCardForm.style.display = 'none';
                    pixForm.style.display = 'block';
                }
            });
        });
        
        // Form submission
        document.querySelector('.btn').addEventListener('click', (e) => {
            e.preventDefault();
            
            // Validate terms checkbox
            const termsChecked = document.getElementById('terms').checked;
            
            if (!termsChecked) {
                alert('Por favor, aceite os termos de serviço para continuar.');
                return;
            }
            
            // Get selected payment method
            const selectedMethod = document.querySelector('input[name="payment-method"]:checked').value;
            
            if (selectedMethod === 'pix') {
                alert('Redirecionando para página de pagamento PIX...');
                // In a real implementation, redirect to PIX payment page
                // window.location.href = '/payment/pix';
            } else {
                // Validate credit card form
                const cardName = document.getElementById('card-name').value;
                const cardNumber = document.getElementById('card-number').value;
                const cardExpiry = document.getElementById('card-expiry').value;
                const cardCvc = document.getElementById('card-cvc').value;
                const cpfCnpj = document.getElementById('cpf-cnpj').value;
                
                if (!cardName || !cardNumber || !cardExpiry || !cardCvc || !cpfCnpj) {
                    alert('Por favor, preencha todos os campos do cartão de crédito.');
                    return;
                }
                
                alert('Processando pagamento com cartão...');
                // In a real implementation, process the payment
                // processPayment();
            }
        });
        
