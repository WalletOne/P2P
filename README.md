# Wallet One P2P #

## Установка через Cocoapods


[CocoaPods](http://cocoapods.org) является менеджером фреймворков/зависимостей для проектов Cocoa. вы можете установить его с помощью следующей команды::

```bash
$ gem install cocoapods
```

Для интеграции P2P Core в Ваш Xcode проект используя CocoaPods, укажите его в Вашем `Podfile`:

```ruby
pod 'P2PCore'
```

```ruby
'0.2.2' # Swift 3.2 (Поддержка только на банковских карт)
'~> 0.2.6' # Swift 4.0 (Поддержка только на банковских карт)
'~> 0.3' # Swift 4.0 (Поддержка разных платежных средств (Карты, Альфа-Клик, Qiwi и т.д.))
```

> P2PCore - предназначен для выполнения сетевых запросов

```ruby
pod 'P2PUI'
```

```ruby
'0.2.2' # Swift 3.2 (Поддержка только на банковских карт)
'~> 0.2.6' # Swift 4.0 (Поддержка только на банковских карт)
'~> 0.3' # Swift 4.0 (Поддержка разных платежных средств (Карты, Альфа-Клик, Qiwi и т.д.))
```

> P2PUI - содержит в себе интерфейсную часть выбора, добавления банковской карты, а так же экран истории выплат и возвратов денежных средтсв.

Затем, запустите команду:

```bash
$ pod install
```
---

После установки импортируйте модули во всех файлах, где они будут использоваться:

```swift
import P2PCore
import P2PUI
```

## Использование

> Рассмотрим в качестве примера фрилансиг площадку.

### Шаг 1 (Конфигурация модуля):

В файле AppDelegate, добавьте конфигурацию в метод `application:didFinishLaunchingWithOptions`

```swift
P2PCore.setPlatform(id: "PLATFORM_ID", signatureKey: "PLATFORM_SIGNATURE_KEY")
```

Значения `PLATFORM_ID` и `PLATFORM_SIGNATURE_KEY` вы получите при регистрации в сервисе [P2P Wallet One](https://www.walletone.com/ru/p2p/).

### Шаг 2 (Конфигурация пользовалетя):

После авторизации пользователя в приложении, необходимо записать в конфигурацию его данные.

Если пользователь выступает в роли заказчика:

```swift
P2PCore.setPayer(id: "PLATFORM_USER_ID", title: "PLATFORM_USER_TITLE", phoneNumber: "PLATFORM_USER_PHONE_NUMBER")
```

Если пользователь выступает в роли исполнителя:

```swift
P2PCore.setBenificiary(id: "PLATFORM_USER_ID", title: "PLATFORM_USER_TITLE", phoneNumber: "PLATFORM_USER_PHONE_NUMBER")
```

Где:

`PLATFORM_USER_ID ` - Идентификатор пользователя в Вашей системе.

`PLATFORM_USER_TITLE ` - Имя пользователя в Вашей системе.

`PLATFORM_USER_PHONE_NUMBER ` - Номер телефона пользователя в Вашей системе.

### Шаг 3 (выбор карты исполнителя):

Если заказчиком во время создания заказа был указан метод расчета "Безопасная сделка ([P2P Wallet One](https://www.walletone.com/ru/p2p/))", то когда исполнитель подает заявку на исполнение заказа, он дожен добавить (выбрать) карту, на которую будет зачислен платеж после выполнения.

Имеется 2 способа добавления (выбора) платежного средства:

**Способ 1 (Используя готовое решение из P2PUI):**

```swift
let vc = PaymentToolsViewController(owner: .benificiary)
vc.delegate = self // PaymentToolsViewControllerDelegate
```

Показать модально, в новом `UINavigationController` (Modal): 

```swift
let nc = UINavigationController(rootViewController: vc)
self.present(nc, animated: true)
```

Показать в текущем `UINavigationController` (Push): 

```swift
self.navigationController?.pushViewController(vc, animated: true)
```

После выбора платежного средства, будет вызван метод делегата `PaymentToolsViewControllerDelegate`:

```swift
func paymentToolsViewController(_ vc: PaymentToolsViewController, didSelect paymentTool: PaymentTool)
```

> В `PaymentToolsViewController` имеется встроенная возможность добавить новое платежное средство.

**Способ 2 (Построить свой View Controller с добавлением, списком платежных средств):**

Получение списка платежных средств исполнителя:

```swift
P2PCore.beneficiariesPaymentTools.paymentTools { paymentTools, error in
	// paymentTools: [PaymentTool]? - Массив объектов [PaymentTool]. Будет nil в случае ошибки запроса
	// error: NSError - Будет nil в случае успешного запроса.
}
```
---

Если у исполнителя нет привязанных раннее платежных средств, то необходимо его добавить используя UIWebView. 

вы можете использовать готовый `LinkPaymentToolViewController`.

```swift
let vc = LinkPaymentToolViewController(delegate: self)
self.navigationController?.pushViewController(vc, animated: true)
```

После того, как исполнитель добавит платежное средство, будет вызван метод делегата `LinkPaymentToolViewControllerDelegate`:

```swift
func linkPaymentToolViewControllerComplete(_ vc: LinkPaymentToolViewController)
```

После добавления платежного средства, Вам необходимо получить его `id`. Для это воспользуйтесь методом получения списка платежных средств (см. выше).

Еслы вы хотите сделать собственный View Controller добавления платежного средства, то для получения `URLRequest` используйте следующий код:

```swift
let request = P2PCore.beneficiariesPaymentTools.linkNewPaymentToolRequest(returnUrl: "RETURN_URL")
```

Где:

`RETURN_URL` - URL на который произойдет переадресация, после завершения добавления.

> ВНИМАНИЕ! выбранный идентификатор платежного средства `paymentTool.id` Вам необходимо записать в заявку исполнителя к задаче. Идентификатор платежного средства исполнителя понадобится при принятии завки заказчиком.

### Шаг 4 (Оплата сделки - HOLD):

Когда заказчик выбрал оптимальное для него предложение исполнителя, необходимо создать сделку на стороне [P2P Wallet One](https://www.walletone.com/ru/p2p/) и оплатить ее (поставить средства в _HOLD_ на платежном средстве заказчика).

Для оплаты необходимо выбрать уже привязанное платежное средство или добавить новое.

выбор платежного средства:

**Способ 1 (Используя готовое решение из P2PUI):**

```swift
let vc = PaymentToolsViewController(owner: .payer)
vc.delegate = self // PaymentToolsViewControllerDelegate
```

Презентовать его можно аналогично двумя способоми, в текущем `UINavigationController` (Push) и в модальном (Modal). Эти способы описаны выше.

Если заказчик выбрал привязанное ранее платежное средство, то вызовится метод делегата `PaymentToolsViewControllerDelegate`:

```swift
func paymentToolsViewController(_ vc: PaymentToolsViewController, didSelect paymentTool: PaymentTool)
```

После выбора платежного средства необходимо создать сделку на стороне P2P Wallet One:

```swift
P2PCore.deals.create(
	dealId: "PLATFORM_DEAL_ID",
	beneficiaryId: "PLATFORM_BENEFICIARY_ID",
	payerPaymentToolId: selectedPaymentTool.id, // опицоинальный
	beneficiaryPaymentToolId: BENEFICIARY_PAYMENT_TOOL_ID,
	amount: 100,
	currencyId: .rub,
	shortDescription: "PLATFORM_DEAL_SHORT_DESCRIPTION",
	fullDescription: "PLATFORM_DEAL_FULL_DESCRIPTION",
	deferPayout: true,
	complete: { (deal, error) in
        if let error = error {
            // process error
        } else  if let deal = deal {
            // Pay deal
        }
    }
)
```

Где:

`PLATFORM_DEAL_ID` - Идентификатор заявки/сделки в Вашей системе.

`PLATFORM_BENEFICIARY_ID` - Идентификатор исполнителя.

`BENEFICIARY_PAYMENT_TOOL_ID` - Идентификатор карты исполнителя, записанные при создании заявки исполнителем.

`PLATFORM_DEAL_SHORT_DESCRIPTION` - Краткое описание сделки. Напимер "Создание сайта".

`PLATFORM_DEAL_FULL_DESCRIPTION ` - Полное описание сделки.

Для оплаты сделки можете использовать готовый View Controller:

```swift
let vc = PayDealViewController(dealId: deal.id, redirectToPaymentToolAddition: redirectToPaymentToolAddition)
vc.delegate = self
```

У `PayDealViewController ` имеется опциональный параметр `authData`. вы можете у пользоателся предварительно запросить _CVV_ выбраной карты и инициализировать контроллер оплаты вместе с _CVV_. В таком случае пользователю не будет предложено ввести _CVV_ на странице оплаты.

Если у пользователя нет приявзанных платежных средств и он на странице списка выберет "Использовать новое платежное средство" то вызовется метод делегата:

```swift
func paymentToolsViewControllerDidSelectLinkNew(_ vc: PaymentToolsViewController)
```

В таком случае, при создании сделки не нужно указывать параметр `payerPaymentToolId` или установите значение `nil`.

**Способ 2 (Построить свой View Controller с добавлением, списком карт):**

Получение списка платежных средств зказчика:

```swift
P2PCore.payersPaymentTools.paymentTools { paymentTools, error in
	// paymentTools: [PaymentTool]? - Массив объектов [PaymentTool]. Будет nil в случае ошибки запроса
	// error: NSError - Будет nil в случае успешного запроса.
}
```
---

Если у заказчика нет привязанных раннее платежных средств, то необходимо оплатить с нового используя UIWebView. 

Для получения `URLRequest` оплаты используйте следующий код:

```swift
let request = P2PCore.deals.payRequest(dealId: "PLATFORM_DEAL_ID", redirectToPaymentToolAddition: true, authData: "CVV/CVC", returnUrl: "RETURN_URL")
```

Где:

`PLATFORM_DEAL_ID` - Идентификатор заявки/сделки в Вашей системе
`CVV/CVC` - Если пользователь выбрал привязанную карту, вы можете нативно запросить у него _CVV/CVC_ карты. В таком случае, заказчику не будет предложено на странице оплаты вводить _CVC/CVV_.
`RETURN_URL` - URL на который произойдет переадресация, после завершения оплаты.


### Шаг 5 (Проверка оплаты):

После оплаты сделки, вы можете узнать статус оплаты используя следующий код:

```swift
P2PCore.deals.status(dealId: self.deal.id) { deal, error 
	switch deal.dealStateId {
	case DealStateIdPaymentProcessing:
	    // В процессе оплаты. Тут необходимо проверить статус еще раз через некоторое время
	case DealStateIdPaymentProcessError:
	    // Возникает в случае ошики оплаты. Например недостаточно средств на карте заказчика
	case DealStateIdPaid:
	    // Средства успешно зарезевированы
	default:
		break
	}
}
```

### Шаг 6 (Подтверждение сделки):

```swift
P2PCore.deals.confirm(dealId: self.deal.id, complete: { deal, error in
    if let error = error {
		// process error
    } else if let deal = deal {
		// ...
	}
})
```

### Шаг 7 (Завершение сделки):

После выполнения работы фрилансером, ему необходимо перевести средства и завершить сделку.

Завершить сделку можно использую следующий код:

```swift
P2PCore.deals.complete(dealId: self.deal.id, complete: { deal, error in
    if let error = error {
		// process error
    } else if let deal = deal {
		switch deal.dealStateId {
		case DealStateIdPayoutProcessing:
			// выплата в процессе
		case DealStateIdPayoutProcessError:
			// Возникла ошибка во время выплаты. Например карта исполнителя заблокирована
		case DealStateIdCompleted:
			// выплптп прошла успешно
		default:
			break
		}
	}
})
```

Если Заказчик не удовлетворен работой, то он может отменить оплату:

```swift
P2PCore.deals.cancel(dealId: self.deal.id, complete: { deal, error in
	if let error = error {
		// process error
	} else if let deal = deal {
		// Process canelation
	}
})
```

### Список (история) выплат исполнителю:

Получить список выплат исполнителю можно двумя способами:

**Способ 1 (Используя готовое решение из P2PUI):**

```swift
let vc = PayoutsViewController(dealId: nil)
navigationController?.pushViewController(vc, animated: true)
```

Где `dealId` можно получить выплату по конкретной сделке.


**Способ 2 (Построить свой View Controller):**

```swift
P2PCore.payouts.payouts(pageNumber: pageNumber, itemsPerPage: itemsPerPage, dealId: dealId) { result, error in
	// result: [Payout]? - Массив с объектами выплат
	// error: NSError? - nil в случае успешного запроса
}
```

### Список (история) возвратов заказчику:

Получить список возвратов заказчику можно двумя способами:

**Способ 1 (Используя готовое решение из P2PUI):**

```swift
let vc = RefundsViewController(dealId: nil)
navigationController?.pushViewController(vc, animated: true)
```

Где `dealId` можно получить выплату по конкретной сделке.


**Способ 2 (Построить свой View Controller):**

```swift
P2PCore.refunds.refunds(pageNumber: pageNumber, itemsPerPage: itemsPerPage, dealId: dealId) { result, error in
	// result: [Payout]? - Массив с объектами выплат
	// error: NSError? - nil в случае успешного запроса
}
```

---

### Массовая оплта сделок:

В `P2PCore` имеется возможность массово завершить сделки.

```swift
P2PCore.dealsManager.complete(dealIds: [String], paymentToolId: String) { result, error in
	// result: [Deal]? - Массив с объектами сделок
	// error: NSError? - nil в случае успешного запроса
}
```

Полный сценарий работы сервиса Вы можете посмотреть в проекте. Таргет `P2PExample`.

### Зависимости:
* [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift)
