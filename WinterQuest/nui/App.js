$('.wrapper').fadeOut(0)
$('.body').fadeOut(0)

let userStatus
let userCandys
let isRegistered

window.addEventListener('message', function(event) {
    let item = event.data;
    
    if ( item.type == 'openUI' ) {

        const cars = Object.entries(item.cars)
        const userData = item.userData

        if (!userData) {
            isRegistered = false
            userStatus = 'Standard'
            userCandys = 0
            $('.wrapper nav .userUtils .status').removeClass('Premium')
            $('.wrapper nav .userUtils .status').addClass('Standard')
            $('.wrapper nav .userUtils .status span').text('Standard')
            $('.wrapper nav .userUtils .candys p span').text('0')
        } else {
            isRegistered = true
            userStatus = userData.status
            userCandys = userData.candy
            $('.wrapper nav .userUtils .status').removeClass('Standard' || 'Premium')
            $('.wrapper nav .userUtils .status').addClass(userStatus)
            $('.wrapper nav .userUtils .status span').text(userStatus)
    
            $('.wrapper nav .userUtils .candys p span').text(userCandys)
        }

        $('.wrapper .getCarList').off('click').on('click', function() {
            $('.mainPage').fadeOut(500)
            setTimeout(() => {
                $('.carList').fadeIn(500)
                $('.carList .slot').remove()
                const reverseRow = cars.reverse()
                reverseRow.forEach(([k, v]) => {
                    renderCarList(v)
                })
            }, 500)
        })

        $('.body').fadeIn(0)
        $('.wrapper').fadeIn(500)
    }
    if ( item.type == 'closeUI' ) {
        $('.wrapper').fadeOut(300)
        $('.body').fadeOut(300)
        $('.carList').fadeOut(0)
        $('.mainPage').fadeIn(0)
    }

    if ( item.type == 'colinda' ) {
        const sound = new Audio('assets/sonudone.mp3')
        sound.play()
    }
})

document.onkeyup = function(data) {
    if (data.which == 27) {
        $.post(`https://${GetParentResourceName()}/closeUI`, JSON.stringify({}));
    }
}

$('.wrapper .getUserPremium').off('click').on('click',function() {
    console.log('cumperi premium')
})

$('.wrapper .claimDailyGift').off('click').on('click',function() {
    console.log('cumperi daily gift')
})

$('.carList').fadeOut(0)

function renderCarList(data) {
    let varStock;
    let varBuy;
    if ( data.stock === 0 ) {
        varStock = 'outOfStock'
        varBuy = 'block'
    } else {
        varStock = 'inStock'
        varBuy = 'active'
    }
    const HTML = `
    <div class="slot ${varStock} data-info="${data}" ">
        <span id="imageContainer">
            <img src="assets/${data.hash}.png">
        </span>
        <div class="text">
            <h1>${data.name}</h1>
            <p>Stock: <span>${data.stock}</span></p>
        </div>
        <span id="carPrice"> 
            <img id="asd" src="assets/candy.png"> 
            <img id="candy" src="assets/candy.png"> 
            <span>${data.price}</span> 
        </span>
        <button class="purchaseCar ${varBuy}">Cumpara</button>
    </div>
    `
    const $slot = $(HTML).prependTo('.wrapper .carList')

    $slot.find('.purchaseCar').off('click').on('click', function () {
        if ($slot.hasClass('inStock')) {
            if ( userCandys >= data.price ) {
                $.post(`https://${GetParentResourceName()}/giveUserCar`, JSON.stringify({
                    hash:data.hash,
                    name:data.name,
                    price:data.price,
                    stock:data.stock
                }))
                $.post(`https://${GetParentResourceName()}/closeUI`, JSON.stringify({}));
            } else {
                $.post(`https://${GetParentResourceName()}/notify`, JSON.stringify({
                    text: 'Nu ai destule <span>Candy</span>  pentru a cumpara'
                }))
            $.post(`https://${GetParentResourceName()}/closeUI`, JSON.stringify({}));
            }
        } else if ($slot.hasClass('outOfStock')) {
            $.post(`https://${GetParentResourceName()}/notify`, JSON.stringify({
                text: 'Nu este stoc la aceasta masina'
            }))
            $.post(`https://${GetParentResourceName()}/closeUI`, JSON.stringify({}));
        }
    })
}

$('.wrapper .premium .getUserPremium').off('click').on('click',function() {
    if ( isRegistered ) {
        if ( userStatus == 'Standard' ) {
            $.post(`https://${GetParentResourceName()}/giveUserPremiumStatus`)
            $.post(`https://${GetParentResourceName()}/closeUI`, JSON.stringify({}))
        } else {
            $.post(`https://${GetParentResourceName()}/notify`, JSON.stringify({
                text: 'Detii deja statutul <span>Premium</span>'
            }))
            $.post(`https://${GetParentResourceName()}/closeUI`, JSON.stringify({}))
        }
    } else {
        $.post(`https://${GetParentResourceName()}/notify`, JSON.stringify({
            text: 'Trebuie mai intai sa incepi event-ul!'
        }))
        $.post(`https://${GetParentResourceName()}/closeUI`, JSON.stringify({}))
    }
})  

const choices = [
    {hash:'burger', name:'Burger Vita', sansa:40},
    {hash:'water', name:'Apa 0.5L', sansa:20},
    {hash:'voucherDrink', name:'Voucher Bauturi', sansa:15},
    {hash:'voucherMeet', name:'Voucher Carne', sansa:15},
    {hash:'bijuteri', name:'Bijuterii', sansa:10},
]

const choicesCandy = [
    {hash:'body_armor', name:'Vesta Anti-Glont', sansa:50},
    {hash:'money', name:'2500', sansa:20},
    {hash:'money', name:'5000', sansa:10},
    {hash:'atxcoins', name:'10', sansa:5},
    
    {hash:'tichetvipb', name:'Vip Bronze 7 Zile', sansa:6},
    {hash:'tichetvips', name:'Vip Silver 7 Zile', sansa:3},
    {hash:'tichetviptrx', name:'Vip Trx 7 Zile', sansa:2},
    {hash:'tichetvipg', name:'Vip Gold 3 Zile', sansa:2},
    {hash:'tichetvipp', name:'Vip Platinun 1 Zile', sansa:2},
    {hash:'tichetvipd', name:'Vip Diamond 1 Zile', sansa:1}
]

function getRandomChoice(choices) {
    const totalChance = choices.reduce((acc, choice) => acc + choice.sansa, 0);
    const random = Math.random() * totalChance;
    let cumulativeChance = 0;

    for (let i = 0; i < choices.length; i++) {
        cumulativeChance += choices[i].sansa;
        if (random < cumulativeChance) {
            return choices[i];
        }
    }
}

$('.wrapper .dailyGift .claimDailyGift').off('click').on('click', function() {
    const selectedChoice = getRandomChoice(choices)
    
    $.post(`https://${GetParentResourceName()}/claimDailyGift`, JSON.stringify({
        hash: selectedChoice.hash,
        name: selectedChoice.name
    }))
    $.post(`https://${GetParentResourceName()}/closeUI`, JSON.stringify({}));
});

const giftPrice = 20

$('.carList .info .openPaidGift').off('click').on('click',function() {

    if ( userCandys >= giftPrice ) {
        const selectedItem = getRandomChoice(choicesCandy)
        $.post(`https://${GetParentResourceName()}/claimPaidGift`, JSON.stringify({
            hash: selectedItem.hash,
            name: selectedItem.name
        }))
        $.post(`https://${GetParentResourceName()}/closeUI`, JSON.stringify({}));
    } else {
        $.post(`https://${GetParentResourceName()}/notify`, JSON.stringify({
            text: 'Nu ai destule <span>Candy-uri</span> pentru a deschide'
        }))
        $.post(`https://${GetParentResourceName()}/closeUI`, JSON.stringify({}));
    }
})

$('.wrapper .startQuest').off('click').on('click',function() {
    $.post(`https://${GetParentResourceName()}/startUserQuest`, JSON.stringify({}))
    $.post(`https://${GetParentResourceName()}/closeUI`, JSON.stringify({}))
})
