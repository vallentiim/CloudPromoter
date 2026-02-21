CREATE DATABASE IF NOT EXISTS promotercloud_db;
USE promotercloud_db;


-- TABELA DE USUÁRIOS (CLIENTES)
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    company_name VARCHAR(100),
    cpf_cnpj VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE
);


-- TABELA DE PLANOS
CREATE TABLE plans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    price_monthly DECIMAL(10,2) NOT NULL,
    price_quarterly DECIMAL(10,2),
    features JSON, -- Armazena as características do plano em formato JSON
    max_campaigns INT DEFAULT 5,
    max_ad_accounts INT DEFAULT 3,
    support_level ENUM('email', 'weekly', 'priority') DEFAULT 'email',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inserindo os planos da PromoterCloud
INSERT INTO plans (name, description, price_monthly, price_quarterly, features, max_campaigns, support_level) VALUES
('Essential', 'Gestão Meta Ads com relatórios semanais', 1500.00, 4050.00, 
 '["meta_ads_management", "weekly_reports", "email_support"]', 3, 'email'),
 
('Pro', 'Tudo do Essential + suporte quinzenal', 3000.00, 8100.00, 
 '["meta_ads_management", "weekly_reports", "email_support", "biweekly_support"]', 10, 'weekly'),
 
('Performance', 'Tudo do Pro + relatórios personalizados e testes A/B', 5000.00, 13500.00, 
 '["meta_ads_management", "weekly_reports", "email_support", "biweekly_support", "custom_reports", "ab_testing"]', 20, 'priority');


-- TABELA DE ASSINATURAS
CREATE TABLE subscriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    plan_id INT NOT NULL,
    status ENUM('active', 'trial', 'canceled', 'expired', 'past_due') DEFAULT 'trial',
    billing_cycle ENUM('monthly', 'quarterly', 'yearly') DEFAULT 'monthly',
    price_paid DECIMAL(10,2) NOT NULL,
    start_date DATE NOT NULL,
    next_billing_date DATE NOT NULL,
    cancel_date DATE NULL,
    trial_ends_at DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES plans(id)
);


-- TABELA DE PAGAMENTOS
CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    subscription_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('pix', 'credit_card', 'debit_card', 'bank_slip') NOT NULL,
    status ENUM('pending', 'approved', 'failed', 'refunded', 'charged_back') DEFAULT 'pending',
    transaction_id VARCHAR(100) UNIQUE,
    payment_date TIMESTAMP NULL,
    due_date DATE NOT NULL,
    card_last_digits VARCHAR(4),
    installments INT DEFAULT 1,
    pix_code TEXT,
    pix_qr_code TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);


-- TABELA DE CAMPANHAS
CREATE TABLE campaigns (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    subscription_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    platform ENUM('meta', 'google', 'tiktok', 'linkedin') DEFAULT 'meta',
    objective VARCHAR(50),
    daily_budget DECIMAL(10,2),
    total_budget DECIMAL(10,2),
    start_date DATE,
    end_date DATE NULL,
    status ENUM('draft', 'active', 'paused', 'completed', 'archived') DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id)
);


-- TABELA DE MÉTRICAS DE CAMPANHA (em tempo real)
CREATE TABLE campaign_metrics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    date DATE NOT NULL,
    impressions INT DEFAULT 0,
    clicks INT DEFAULT 0,
    conversions INT DEFAULT 0,
    ctr DECIMAL(5,2) DEFAULT 0.00,
    cpc DECIMAL(10,2) DEFAULT 0.00,
    cpm DECIMAL(10,2) DEFAULT 0.00,
    roas DECIMAL(5,2) DEFAULT 0.00,
    spent DECIMAL(10,2) DEFAULT 0.00,
    revenue DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE CASCADE,
    UNIQUE KEY unique_campaign_date (campaign_id, date)
);


-- TABELA DE CHAMADOS (SUPORTE)
CREATE TABLE support_tickets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    subscription_id INT NOT NULL,
    ticket_number VARCHAR(20) UNIQUE,
    subject VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    status ENUM('open', 'in_progress', 'waiting_client', 'resolved', 'closed') DEFAULT 'open',
    category ENUM('technical', 'billing', 'campaign', 'other') DEFAULT 'technical',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    closed_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id)
);

-- TABELA DE RESPOSTAS DOS CHAMADOS
CREATE TABLE ticket_responses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    user_id INT NULL, -- Pode ser NULL se for resposta do suporte (admin)
    is_support BOOLEAN DEFAULT FALSE,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES support_tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- TABELA DE LOGS DE ACESSO
CREATE TABLE access_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    action VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ÍNDICES PARA MELHOR PERFORMANCE
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_cpf_cnpj ON users(cpf_cnpj);
CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_next_billing ON subscriptions(next_billing_date);
CREATE INDEX idx_payments_subscription ON payments(subscription_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_due_date ON payments(due_date);
CREATE INDEX idx_campaigns_user ON campaigns(user_id);
CREATE INDEX idx_campaigns_status ON campaigns(status);
CREATE INDEX idx_campaign_metrics_date ON campaign_metrics(date);
CREATE INDEX idx_support_tickets_user ON support_tickets(user_id);
CREATE INDEX idx_support_tickets_status ON support_tickets(status);


-- View de resumo de assinaturas ativas
CREATE VIEW vw_active_subscriptions AS
SELECT 
    s.id AS subscription_id,
    u.name AS user_name,
    u.email,
    p.name AS plan_name,
    s.status,
    s.next_billing_date,
    s.price_paid,
    DATEDIFF(s.next_billing_date, CURDATE()) AS days_until_billing
FROM subscriptions s
JOIN users u ON s.user_id = u.id
JOIN plans p ON s.plan_id = p.id
WHERE s.status = 'active';

-- View de desempenho de campanhas por usuário
CREATE VIEW vw_campaign_performance AS
SELECT 
    u.id AS user_id,
    u.name AS user_name,
    c.id AS campaign_id,
    c.name AS campaign_name,
    COUNT(cm.id) AS days_tracked,
    SUM(cm.impressions) AS total_impressions,
    SUM(cm.clicks) AS total_clicks,
    SUM(cm.conversions) AS total_conversions,
    ROUND(AVG(cm.ctr), 2) AS avg_ctr,
    ROUND(SUM(cm.spent), 2) AS total_spent,
    ROUND(SUM(cm.revenue), 2) AS total_revenue,
    ROUND((SUM(cm.revenue) - SUM(cm.spent)) / SUM(cm.spent) * 100, 2) AS roi_percentage
FROM users u
JOIN campaigns c ON u.id = c.user_id
LEFT JOIN campaign_metrics cm ON c.id = cm.campaign_id
GROUP BY u.id, c.id;


-- Procedure para renovar assinaturas automaticamente
DELIMITER //
CREATE PROCEDURE sp_renew_subscriptions()
BEGIN
    -- Busca assinaturas que vencem hoje
    UPDATE subscriptions 
    SET next_billing_date = DATE_ADD(next_billing_date, INTERVAL 1 MONTH)
    WHERE next_billing_date = CURDATE() 
    AND status = 'active';
    
    -- Cria novos registros de pagamento pendente
    INSERT INTO payments (subscription_id, user_id, amount, due_date, status)
    SELECT 
        s.id,
        s.user_id,
        s.price_paid,
        CURDATE(),
        'pending'
    FROM subscriptions s
    WHERE s.next_billing_date = CURDATE() 
    AND s.status = 'active';
END//
DELIMITER ;

-- Procedure para criar chamado com número automático
DELIMITER //
CREATE PROCEDURE sp_create_ticket(
    IN p_user_id INT,
    IN p_subscription_id INT,
    IN p_subject VARCHAR(200),
    IN p_description TEXT,
    IN p_priority ENUM('low', 'medium', 'high', 'urgent'),
    IN p_category ENUM('technical', 'billing', 'campaign', 'other')
)
BEGIN
    DECLARE v_ticket_number VARCHAR(20);
    DECLARE v_year VARCHAR(4);
    DECLARE v_sequence INT;
    
    SET v_year = YEAR(CURDATE());
    
    -- Gera número sequencial do ticket
    SELECT COALESCE(MAX(CAST(SUBSTRING_INDEX(ticket_number, '/', -1) AS UNSIGNED)), 0) + 1
    INTO v_sequence
    FROM support_tickets
    WHERE ticket_number LIKE CONCAT('TKT-', v_year, '/%');
    
    SET v_ticket_number = CONCAT('TKT-', v_year, '/', LPAD(v_sequence, 4, '0'));
    
    -- Insere o ticket
    INSERT INTO support_tickets (
        user_id, subscription_id, ticket_number, subject, 
        description, priority, category, status
    ) VALUES (
        p_user_id, p_subscription_id, v_ticket_number, p_subject,
        p_description, p_priority, p_category, 'open'
    );
    
    -- Retorna o número do ticket criado
    SELECT v_ticket_number AS created_ticket_number;
END//
DELIMITER ;


-- Trigger para atualizar data de último login
DELIMITER //
CREATE TRIGGER trg_update_last_login
AFTER INSERT ON access_logs
FOR EACH ROW
BEGIN
    IF NEW.action = 'login' THEN
        UPDATE users SET last_login = NEW.created_at WHERE id = NEW.user_id;
    END IF;
END//
DELIMITER ;

-- Trigger para verificar limites de campanhas antes de inserir
DELIMITER //
CREATE TRIGGER trg_check_campaign_limit
BEFORE INSERT ON campaigns
FOR EACH ROW
BEGIN
    DECLARE v_max_campaigns INT;
    DECLARE v_current_campaigns INT;
    
    -- Busca limite de campanhas do plano
    SELECT p.max_campaigns INTO v_max_campaigns
    FROM subscriptions s
    JOIN plans p ON s.plan_id = p.id
    WHERE s.id = NEW.subscription_id AND s.status = 'active';
    
    -- Conta campanhas atuais
    SELECT COUNT(*) INTO v_current_campaigns
    FROM campaigns
    WHERE subscription_id = NEW.subscription_id AND status IN ('active', 'draft');
    
    IF v_current_campaigns >= v_max_campaigns THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Limite de campanhas atingido para este plano';
    END IF;
END//
DELIMITER ;


-- Inserindo usuários de exemplo
INSERT INTO users (name, email, password_hash, phone, company_name, cpf_cnpj) VALUES
('João Silva', 'joao@email.com', '$2y$10$YourHashHere', '(81) 99999-0001', 'Tech Solutions', '123.456.789-00'),
('Maria Santos', 'maria@email.com', '$2y$10$YourHashHere', '(81) 99999-0002', 'Digital Agency', '987.654.321-00');

-- Inserindo assinaturas
INSERT INTO subscriptions (user_id, plan_id, status, billing_cycle, price_paid, start_date, next_billing_date) VALUES
(1, 3, 'active', 'monthly', 5000.00, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 MONTH)),
(2, 2, 'active', 'quarterly', 8100.00, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 3 MONTH));

-- Inserindo campanhas de exemplo
INSERT INTO campaigns (user_id, subscription_id, name, platform, objective, daily_budget, total_budget, status) VALUES
(1, 1, 'Campanha Verão 2025', 'meta', 'conversions', 150.00, 4500.00, 'active'),
(1, 1, 'Retargeting - Site', 'meta', 'traffic', 80.00, 2400.00, 'active'),
(2, 2, 'Brand Awareness Q1', 'google', 'awareness', 200.00, 6000.00, 'draft');

-- Inserindo métricas de exemplo
INSERT INTO campaign_metrics (campaign_id, date, impressions, clicks, conversions, ctr, cpc, spent, revenue) VALUES
(1, CURDATE(), 15000, 450, 15, 3.00, 3.50, 1575.00, 5000.00),
(1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 14200, 426, 14, 3.00, 3.50, 1491.00, 4800.00);