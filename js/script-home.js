const loginModal = document.getElementById('loginModal');
        const openLoginBtn = document.getElementById('openLogin');
        const closeLoginBtn = document.getElementById('closeLogin');
        const loginForm = document.getElementById('loginForm');
        
        openLoginBtn.addEventListener('click', () => {
            loginModal.style.display = 'flex';
        });
        
        closeLoginBtn.addEventListener('click', () => {
            loginModal.style.display = 'none';
        });
        
        window.addEventListener('click', (e) => {
            if (e.target === loginModal) {
                loginModal.style.display = 'none';
            }
        });
        
        // LOGIN REALIZADO
        loginForm.addEventListener('submit', (e) => {
            e.preventDefault();
            alert('Login realizado com sucesso! Redirecionando para o painel...');
            loginModal.style.display = 'none';

        });
        
        // PLANO SELECIONADO
        document.querySelectorAll('.plan-btn').forEach(button => {
            button.addEventListener('click', function() {
                const plan = this.getAttribute('data-plan');
                alert(`Você selecionou o plano ${plan}. Em uma implementação real, isto redirecionaria para o checkout.`);
            });
        });
        
        // FORMULÁRIO ENVIADO
        document.getElementById('contactForm').addEventListener('submit', function(e) {
            e.preventDefault();
            alert('Formulário enviado com sucesso! Entraremos em contato em breve.');
            this.reset();
        });
    //FUNÇÃO DO BOTÃO DE LOGIN PARA ACESSAR A PÁGINA DE USUÁRIO
    function btnlogin() {
        window.location.href = "../user.html"
    }